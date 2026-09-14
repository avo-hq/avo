require "rails_helper"
require_relative "../../../../lib/generators/avo/eject_generator"

RSpec.feature "eject generator", type: :feature, acquire_lock: :generator do
  let(:overrides_path) { Rails.root.join("app", "assets", "stylesheets", "avo-overrides.css") }
  let(:overrides_js_path) { Rails.root.join("app", "assets", "javascripts", "avo-overrides.js") }
  let(:theme_views_path) { Rails.root.join("app", "views", "avo", "themes", "tidepool") }

  before do
    # Stub the shell's yes? (normal arity) rather than the generator's, which
    # Thor delegates via a `def yes?(*args)` splat that trips rspec-mocks'
    # any_instance handling ("__yes?_without_any_instance__ takes -1 argument").
    allow_any_instance_of(Thor::Shell::Basic)
      .to receive(:yes?)
      .and_return(true)
  end

  after do
    FileUtils.rm_f(overrides_path)
    FileUtils.rm_f(overrides_js_path)
    FileUtils.rm_rf(theme_views_path)
  end

  it "ejects the Avo overrides stylesheet" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":avo_overrides_css", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_path).to exist
    expect(overrides_path.read).to be_blank
  end

  it "ejects the Avo overrides javascript" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":avo_overrides_js", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_js_path).to exist
    expect(overrides_js_path.read).to be_blank
  end

  it "ejects both Avo overrides assets at once" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":asset_overrides", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_path).to exist
    expect(overrides_js_path).to exist
  end

  describe "--theme" do
    def eject(*args)
      Rails::Generators.invoke("avo:eject", [*args, "--skip-avo-version"], {destination_root: Rails.root})
    end

    it "ejects a named partial into the theme's views directory, keeping its path below app/views" do
      eject "--partial", ":logo", "--theme", "tidepool"

      destination = theme_views_path.join("avo", "partials", "_logo.html.erb")
      expect(destination).to exist
      expect(destination.read).to eq Avo::Engine.root.join("app/views/avo/partials/_logo.html.erb").read
      expect(Rails.root.join("app", "views", "avo", "partials", "_logo.html.erb")).not_to exist
    end

    it "ejects a partial given by path into the theme's views directory" do
      eject "--partial", "app/views/layouts/avo/application.html.erb", "--theme", "tidepool"

      expect(theme_views_path.join("layouts", "avo", "application.html.erb")).to exist
      expect(Rails.root.join("app", "views", "layouts", "avo", "application.html.erb")).not_to exist
    end

    it "refuses to put an asset override into a theme" do
      expect { eject "--partial", ":avo_overrides_css", "--theme", "tidepool" }
        .to output(/Themes override partials only/).to_stdout

      expect(overrides_path).not_to exist
      expect(theme_views_path).not_to exist
    end

    it "refuses to put a component into a theme" do
      expect { eject "--component", "Avo::Index::TableRowComponent", "--theme", "tidepool" }
        .to output(/Themes override partials only/).to_stdout

      expect(Rails.root.join("app", "components", "avo", "index", "table_row_component.rb")).not_to exist
    end

    it "refuses to put a controller into a theme" do
      expect { eject "--controller", "application_controller", "--theme", "tidepool" }
        .to output(/Themes override partials only/).to_stdout

      expect(Rails.root.join("app", "controllers", "avo", "application_controller.rb")).not_to exist
    end
  end
end
