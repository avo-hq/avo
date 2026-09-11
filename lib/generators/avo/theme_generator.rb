require_relative "named_base_generator"

module Generators
  module Avo
    # Scaffolds a theme: a manifest class plus a stylesheet listing every public
    # token, commented out, so an author (or an agent) uncomments what the look
    # sets. With `--gem` the same theme is laid out as a publishable engine gem
    # named `avo-<name>_theme` (see docs/plans/2026-09-03-001-feat-themes-plan.md,
    # "Gem naming").
    #
    #   rails g avo:theme coastal
    #   rails g avo:theme midnight --scheme dark
    #   rails g avo:theme coastal --gem --path ../
    class ThemeGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:theme"
      desc "Add an Avo theme to your app, or scaffold it as a publishable gem with --gem."

      class_option :gem,
        desc: "Scaffold the theme as a publishable gem (avo-<name>_theme) instead of a local theme",
        type: :boolean,
        default: false

      class_option :path,
        desc: "Directory the gem is created in, relative to the app root. Defaults to the app root. Only with --gem",
        type: :string,
        required: false

      class_option :scheme,
        desc: "The color scheme the theme is drawn for: light or dark. Avo forces it while the theme is active",
        type: :string,
        default: "light"

      def create
        return invalid_name unless ::Avo::BaseTheme::ID_FORMAT.match?(theme_id)
        return invalid_scheme unless ::Avo::BaseTheme::SCHEMES.include?(theme_scheme)

        options[:gem] ? create_gem : create_local
      end

      no_tasks do
        # `Coastal`, `coastal`, `coastal_theme` and `CoastalTheme` all name the
        # `coastal` theme; the `_theme` suffix belongs to the gem name only.
        def theme_id
          @theme_id ||= name.to_s.underscore.delete_suffix("_theme")
        end

        def theme_class_name = theme_id.camelize

        def theme_title = theme_id.titleize

        def theme_scheme = options[:scheme].to_s.downcase.to_sym

        def dark? = theme_scheme == :dark

        def gem_name = "avo-#{theme_id}_theme"

        # `Avo::CoastalTheme` — the gem's own namespace. The theme class is
        # `Avo::CoastalTheme::Theme`, never `Avo::Themes::Coastal`, which is the
        # constant a host app's `app/avo/themes/coastal.rb` owns.
        def gem_module_name = "#{theme_class_name}Theme"

        def gem_root
          @gem_root ||= File.expand_path(File.join(options[:path].presence || ".", gem_name), destination_root)
        end

        def gem_relative_root
          Pathname.new(gem_root).relative_path_from(Pathname.new(destination_root)).to_s
        end

        def stylesheet_path = "app/assets/stylesheets/avo/themes/#{theme_id}.css"

        # The `>= major.minor` floor the gemspec pins: a theme written against
        # 4.2's token catalog has no reason to refuse 4.3.
        def avo_version_floor = ::Avo::VERSION.split(".").first(2).join(".")

        def catalog = ::Avo::Themes::Catalog

        def create_local
          template "theme/theme.tt", "app/avo/themes/#{theme_id}.rb"
          template "theme/stylesheet.tt", stylesheet_path

          say "\nNext steps:", :green
          say "  1. Restart the server so Avo registers the theme.", :green
          say "  2. Open the appearance picker and choose \"#{theme_title}\".", :green
          say "  3. Override a partial inside the theme with:", :green
          say "     rails g avo:eject --partial :logo --theme #{theme_id}", :green
        end

        def create_gem
          template "theme/gem/gemspec.tt", gem_file("#{gem_name}.gemspec")
          template "theme/gem/lib.tt", gem_file("lib/avo/#{theme_id}_theme.rb")
          template "theme/gem/version.tt", gem_file("lib/avo/#{theme_id}_theme/version.rb")
          template "theme/gem/engine.tt", gem_file("lib/avo/#{theme_id}_theme/engine.rb")
          template "theme/gem/theme.tt", gem_file("lib/avo/#{theme_id}_theme/theme.rb")
          template "theme/stylesheet.tt", gem_file(stylesheet_path)
          template "theme/gem/manifest.tt", gem_file("app/assets/config/#{gem_name}_manifest.js")
          create_file gem_file("app/assets/images/avo/themes/#{theme_id}/.keep"), ""
          create_file gem_file("app/views/avo/themes/#{theme_id}/.keep"), ""
          template "theme/gem/README.tt", gem_file("README.md")
          template "theme/gem/NOTICE.tt", gem_file("NOTICE")

          say "\nNext steps:", :green
          say "  1. Add the gem to your Gemfile (the path: option is for local development):", :green
          say "     gem \"#{gem_name}\", path: \"#{gem_relative_root}\"", :green
          say "  2. Run bundle install and restart the server.", :green
          say "  3. Open the appearance picker and choose \"#{theme_title}\".", :green
          say "  4. When it looks right, publish it: see #{gem_relative_root}/README.md.", :green
        end

        def gem_file(path) = File.join(gem_root, path)

        def invalid_scheme
          say "--scheme must be one of #{::Avo::BaseTheme::SCHEMES.join(", ")}; got #{options[:scheme].inspect}.", :red
        end

        def invalid_name
          say "Theme names must match #{::Avo::BaseTheme::ID_FORMAT.inspect} once underscored; " \
            "got #{theme_id.inspect} from #{name.inspect}. Start with a letter and use letters, digits and underscores.", :red
        end
      end
    end
  end
end
