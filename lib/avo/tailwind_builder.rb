require "fileutils"

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

    def self.custom_build_exists?
      return false unless defined?(Rails)

      Rails.root.join("app", "assets", "builds", "avo.tailwind.css").exist?
    end

    def self.procfile_has_avo_tailwind_watcher?
      path = Rails.root.join("Procfile.dev")
      return false unless path.exist?

      File.read(path).include?("avo:tailwindcss")
    end

    def build
      return true unless self.class.tailwindcss_available?

      generate_input_file
      success = run_tailwindcss("--minify")
      log_build_failure unless success
      success
    end

    def watch
      return unless self.class.tailwindcss_available?

      generate_input_file
      signature = host_avo_stylesheets_signature

      pid = spawn_tailwindcss("--minify", "--watch")

      begin
        loop do
          _, status = Process.waitpid2(pid, Process::WNOHANG)
          break if status

          new_signature = host_avo_stylesheets_signature
          if new_signature != signature
            signature = new_signature
            generate_input_file
          end

          sleep 1
        end
      rescue Interrupt
        Process.kill("TERM", pid)
        raise
      end
    end

    private

    def tmp_input_dir
      Rails.root.join("tmp", "avo")
    end

    def input_path
      tmp_input_dir.join("avo.tailwind.input.css")
    end

    def output_path
      Rails.root.join("app", "assets", "builds", "avo.tailwind.css")
    end

    def generate_input_file
      FileUtils.mkdir_p(tmp_input_dir)

      lines = []
      # Input lives under tmp/avo/; without `source("../../")` Tailwind v4 only scans near this file, so
      # classes in app/views/**/*.erb (and the rest of the app) are never detected.
      lines << %(@layer theme, base, components, utilities;)

      lines << %(@import "tailwindcss/theme.css" layer(theme);)
      lines << %(@import "tailwindcss/utilities.css" layer(utilities);)
      lines << %(@source "../../";)
      
      collect_host_avo_stylesheets.each do |path|
        lines << %(@import "#{path}";)
      end

      File.write(input_path, lines.join("\n") + "\n")
    end

    def collect_host_avo_stylesheets
      base = Rails.root.join("app", "assets", "stylesheets", "avo")
      return [] unless Dir.exist?(base)

      Dir
        .glob(base.join("**", "*.css"))
        .select { |path| File.file?(path) }
        .sort
        .map { |path| Pathname.new(path).relative_path_from(tmp_input_dir).to_s.tr("\\", "/") }
    end

    def host_avo_stylesheets_signature
      collect_host_avo_stylesheets.join("\n")
    end

    def run_tailwindcss(*args)
      require "tailwindcss/ruby"

      FileUtils.mkdir_p(output_path.dirname)

      Dir.chdir(Rails.root) do
        Kernel.system(
          Tailwindcss::Ruby.executable,
          "-i", input_path.to_s,
          "-o", output_path.to_s,
          *args
        )
      end
    end

    def spawn_tailwindcss(*args)
      require "tailwindcss/ruby"

      FileUtils.mkdir_p(output_path.dirname)

      Process.spawn(
        Tailwindcss::Ruby.executable,
        "-i", input_path.to_s,
        "-o", output_path.to_s,
        *args,
        chdir: Rails.root.to_s
      )
    end

    def log_build_failure
      message = "[Avo] avo:tailwindcss build failed."
      Rails.logger.warn(message) if defined?(Rails) && Rails.logger
      warn message
    end
  end
end
