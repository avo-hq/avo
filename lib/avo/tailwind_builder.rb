require "fileutils"
require "pathname"

module Avo
  class TailwindBuilder
    def self.build
      new.build
    end

    def self.watch
      new.watch
    end

    def self.tailwindcss_available?
      require "tailwindcss/ruby"
      true
    rescue LoadError
      false
    end

    def self.enabled?
      Avo.configuration.tailwindcss_integration_enabled && tailwindcss_available?
    end

    def build
      return true unless self.class.enabled?

      ensure_node_modules
      run_engine_css_prebuilds
      generate_input_file
      success = run_tailwindcss("--minify")
      log_build_failure unless success
      success
    end

    def watch
      return true unless self.class.enabled?

      ensure_node_modules
      run_engine_css_prebuilds
      generate_input_file
      run_tailwindcss("--watch")
    end

    private

    def run_engine_css_prebuilds
      roots = [Avo::Engine.root] + Avo.plugin_manager.engines.map { |e| e[:klass]&.root }.compact

      roots.uniq.each do |root|
        next unless root.directory?

        prebuild = root.join("bin", "prebuild_css")
        next unless prebuild.exist?

        Dir.chdir(root) do
          Kernel.system("ruby", prebuild.to_s)
        end
      end
    end

    def ensure_node_modules
      engine_root = Avo::Engine.root
      package_json = engine_root.join("package.json")
      node_modules = engine_root.join("node_modules")

      return unless package_json.exist?
      return if node_modules.directory?

      # Avo's stylesheet imports include CSS from npm packages. When running from source (or in some
      # packaging setups), `node_modules/` may not exist yet, so Tailwind's CSS resolver fails.
      success = Dir.chdir(engine_root) { Kernel.system("yarn", "install", "--frozen-lockfile") }
      warn "[Avo] `yarn install` failed; Tailwind build may fail." unless success
    end

    def tmp_input_dir
      Rails.root.join("tmp", "avo")
    end

    def input_path
      tmp_input_dir.join("avo.tailwind.input.css")
    end

    def output_path
      Rails.root.join("app", "assets", "builds", "avo", "application.css")
    end

    def generate_input_file
      FileUtils.mkdir_p(tmp_input_dir)

      lines = []
      # Input lives under tmp/avo/; without `@source "../../"` Tailwind v4 only scans near this file, so
      # classes in app/views/**/*.erb (and the rest of the app) are never detected.

      append_plugin_engine_tailwind_sources(lines)
      collect_host_avo_stylesheets.each do |path|
        lines << %(@import "#{path}";)
      end

      lines << %(@source "../../";)

      File.write(input_path, lines.join("\n") + "\n")
    end

    def append_plugin_engine_tailwind_sources(lines)
      # Include Avo itself (the core engine) in Tailwind's scan paths.
      lines << %(@source "#{relative_to_tmp(Avo::Engine.root)}";)
      append_engine_stylesheets(lines, Avo::Engine.root)

      Avo.plugin_manager.engines.each do |entry|
        root = entry[:klass].root
        next unless root&.directory?

        lines << %(@source "#{relative_to_tmp(root)}";)
        append_engine_stylesheets(lines, root)
      end
    end

    def append_engine_stylesheets(lines, engine_root)
      stylesheets_root = engine_root.join("app", "assets", "stylesheets")
      return unless stylesheets_root.directory?

      # Some engines ship `app/assets/stylesheets/application.css` directly (no namespace folder).
      root_application = stylesheets_root.join("application.css")
      lines << %(@import "#{relative_to_tmp(root_application)}";) if root_application.exist?

      # Most engines namespace their assets under `app/assets/stylesheets/<namespace>/application.css`.
      Dir.children(stylesheets_root).sort.each do |entry|
        next if entry.start_with?(".")

        namespaced_application = stylesheets_root.join(entry, "application.css")
        lines << %(@import "#{relative_to_tmp(namespaced_application)}";) if namespaced_application.exist?
      end
    end

    def relative_to_tmp(absolute)
      Pathname.new(absolute).expand_path.relative_path_from(tmp_input_dir.expand_path).to_s.tr("\\", "/")
    end

    def collect_host_avo_stylesheets
      base = Rails.root.join("app", "assets", "stylesheets", "avo")
      return [] unless Dir.exist?(base)

      Dir
        .glob(base.join("**", "*.css"))
        .select { |path| File.file?(path) }
        .sort
        .map { |path| relative_to_tmp(path) }
    end

    def run_tailwindcss(*tailwind_args)
      require "tailwindcss/ruby"

      FileUtils.mkdir_p(output_path.dirname)

      Dir.chdir(Rails.root) do
        Kernel.system(
          Tailwindcss::Ruby.executable,
          "-i", input_path.to_s,
          "-o", output_path.to_s,
          *tailwind_args
        )
      end
    end

    def log_build_failure
      message = "[Avo] avo:tailwindcss build failed."
      Rails.logger.warn(message) if defined?(Rails) && Rails.logger
      warn message
    end
  end
end
