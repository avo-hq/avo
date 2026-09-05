require "rails_helper"
require "rails/generators"
require "tmpdir"
# lib/generators is outside the Zeitwerk root, so the class is only defined once
# something invokes it. Requiring it keeps the examples order-independent.
require "generators/avo/theme_generator"

RSpec.feature "theme generator", type: :feature, acquire_lock: :generator do
  # Everything is written into a throwaway root rather than the dummy app: a
  # theme class left behind in app/avo/themes would register itself on the
  # next boot of every other spec process. The fake app sits one level down so
  # `--path ../vendor` still lands inside the temporary directory.
  around do |example|
    Dir.mktmpdir("avo-theme-generator") do |dir|
      @root = Pathname.new(dir).join("app")
      @root.mkpath
      example.run
    end
  end

  def generate(*args, quiet: true)
    Rails::Generators.invoke("avo:theme", [*args, *("-q" if quiet)], {destination_root: @root.to_s})
  end

  def file(*path) = @root.join(*path)

  describe "a local theme" do
    let(:manifest) { file("app/avo/themes/lagoon.rb") }
    let(:stylesheet) { file("app/assets/stylesheets/avo/themes/lagoon.css") }

    before { generate "lagoon" }

    it "writes the manifest with the derived defaults commented out" do
      expect(manifest).to exist

      content = manifest.read
      expect(content).to include "class Avo::Themes::Lagoon < Avo::BaseTheme"
      expect(content).to include 'self.title = "Lagoon"'
      expect(content).to include "self.description ="
      expect(content).to include "# self.id = :lagoon"
      expect(content).to include '# self.stylesheet = "avo/themes/lagoon"'
      expect(content).to include '# self.views = root.join("app/views/avo/themes/lagoon")'
      expect(content).to include "self.scheme = :light"
      expect(content).to include "# self.lock = [:neutral, :accent, :scheme]"
      expect(content).to include "# self.appearance = {"
      Avo::BaseTheme::APPEARANCE_KEYS.each do |key|
        expect(content).to include "#   #{key}:"
      end
    end

    it "writes a stylesheet scoped to the theme class that lists every catalog token" do
      expect(stylesheet).to exist

      content = stylesheet.read
      expect(content).to include "@layer base {"
      expect(content).to include ".avo-theme-lagoon {"
      expect(content.lines.grep(/^\s+\.dark/)).to be_empty
      expect(content).to include "drawn for the light scheme"
      expect(content).to include "The navbar does not have to be dark"

      Avo::Themes::Catalog.names.each do |token|
        expect(content).to include "/* #{token}: ; */"
      end
      Avo::Themes::Catalog::GROUPS.each_value do |heading|
        expect(content).to include "/* #{heading} */"
      end
      expect(content).to include "(inherits from --color-avo-neutral-50)"
      expect(content).to include "Required: a complete theme sets these"
    end

    it "leaves every token commented out" do
      declared = stylesheet.read.lines.grep(/^\s*--/)

      expect(declared).to be_empty
    end
  end

  describe "--scheme" do
    it "writes a dark theme" do
      generate "abyss", "--scheme", "dark"

      expect(file("app/avo/themes/abyss.rb").read).to include "self.scheme = :dark"
      expect(file("app/assets/stylesheets/avo/themes/abyss.css").read).to include "drawn for the dark scheme"
    end

    it "refuses anything but light or dark" do
      expect { generate "abyss", "--scheme", "auto", quiet: false }.to output(/--scheme must be one of light, dark/).to_stdout

      expect(file("app/avo/themes")).not_to exist
    end
  end

  describe "the name" do
    it "underscores it and drops a _theme suffix, so the id is the bare name" do
      generate "CoastalTheme"

      expect(file("app/avo/themes/coastal.rb").read).to include "class Avo::Themes::Coastal < Avo::BaseTheme"
      expect(file("app/assets/stylesheets/avo/themes/coastal.css")).to exist
    end

    it "refuses one that cannot be a theme id" do
      expect { generate "2fast", quiet: false }.to output(/Theme names must match/).to_stdout

      expect(file("app/avo/themes")).not_to exist
    end
  end

  describe "--gem" do
    let(:gem_root) { file("avo-lagoon_theme") }

    before { generate "lagoon", "--gem" }

    it "lays out a publishable engine gem next to the app" do
      %w[
        avo-lagoon_theme.gemspec
        lib/avo/lagoon_theme.rb
        lib/avo/lagoon_theme/version.rb
        lib/avo/lagoon_theme/engine.rb
        lib/avo/lagoon_theme/theme.rb
        app/assets/stylesheets/avo/themes/lagoon.css
        app/assets/config/avo-lagoon_theme_manifest.js
        app/assets/images/avo/themes/lagoon/.keep
        app/views/avo/themes/lagoon/.keep
        README.md
        NOTICE
      ].each do |path|
        expect(gem_root.join(path)).to exist, "expected #{path} to be generated"
      end
    end

    it "names the gem and pins the avo floor in the gemspec" do
      gemspec = gem_root.join("avo-lagoon_theme.gemspec").read

      expect(gemspec).to include 'spec.name = "avo-lagoon_theme"'
      expect(gemspec).to include "spec.version = Avo::LagoonTheme::VERSION"
      expect(gemspec).to include 'spec.add_dependency "avo", ">= 4.2"'
      expect(gem_root.join("lib/avo/lagoon_theme/version.rb").read).to include 'VERSION = "0.1.0"'
    end

    it "defines the theme under the gem's namespace with an explicit id" do
      theme = gem_root.join("lib/avo/lagoon_theme/theme.rb").read

      expect(theme).to include "module LagoonTheme"
      expect(theme).to include "class Theme < Avo::BaseTheme"
      expect(theme).to include "self.id = :lagoon"
      expect(theme).to include "self.scheme = :light"
      expect(theme).not_to include "Avo::Themes::Lagoon <"
    end

    it "ships a minimal engine that only precompiles the manifest under Sprockets" do
      engine = gem_root.join("lib/avo/lagoon_theme/engine.rb").read

      expect(engine).to include "class Engine < ::Rails::Engine"
      expect(engine).to include "isolate_namespace Avo::LagoonTheme"
      expect(engine).to include "app.config.assets.precompile += %w[avo-lagoon_theme_manifest.js]"

      code = engine.lines.reject { |line| line.strip.start_with?("#") }.join
      expect(code).not_to include "asset_manager"
      expect(code).not_to include "plugin_manager"
    end

    it "links the stylesheets and images from the manifest" do
      manifest = gem_root.join("app/assets/config/avo-lagoon_theme_manifest.js").read

      expect(manifest).to include "//= link_tree ../stylesheets"
      expect(manifest).to include "//= link_tree ../images"
    end

    it "documents the install and publish steps" do
      readme = gem_root.join("README.md").read

      expect(readme).to include 'gem "avo-lagoon_theme"'
      expect(readme).to include 'gem "avo-lagoon_theme", path: "avo-lagoon_theme"'
      expect(readme).to include "gem build avo-lagoon_theme.gemspec"
      expect(readme).to include "gem push avo-lagoon_theme-0.1.0.gem"
    end

    it "uses the same stylesheet template as a local theme" do
      content = gem_root.join("app/assets/stylesheets/avo/themes/lagoon.css").read

      expect(content).to include ".avo-theme-lagoon {"
      Avo::Themes::Catalog.names.each { |token| expect(content).to include token }
    end
  end

  describe "--gem --path" do
    it "creates the gem under the given directory, relative to the app root" do
      generate "lagoon", "--gem", "--path", "../vendor"

      expect(file("../vendor/avo-lagoon_theme/avo-lagoon_theme.gemspec")).to exist
      expect(file("avo-lagoon_theme")).not_to exist
      expect(file("../vendor/avo-lagoon_theme/README.md").read).to include 'path: "../vendor/avo-lagoon_theme"'
    end
  end
end
