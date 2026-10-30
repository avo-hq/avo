module Avo
  module Services
    # Runs `bin/rails avo:update` in the background from the status page and reports how it went. The run outlives
    # the request, so its state lives in files under tmp/ that any server process can read.
    class Updater
      class << self
        def allowed?
          Rails.env.development?
        end

        def start
          return false if running?

          FileUtils.rm_rf(dir)
          FileUtils.mkdir_p(dir)
          # The versions before the run, so the updates page can list what the run brought in.
          File.write(dir.join("from.json"), GemVersions.installed.to_json)

          # The shell records the exit status, which a detached child's parent can't collect.
          pid = Bundler.with_original_env do
            Process.spawn(
              "sh", "-c", 'bin/rails avo:update > "$1" 2>&1; echo $? > "$2"', "sh", log_path.to_s, exit_path.to_s,
              chdir: Rails.root.to_s, pgroup: true
            )
          end
          Process.detach(pid)
          File.write(dir.join("pid"), pid)
          true
        end

        # :idle, :running, :succeeded or :failed
        def state
          return :idle unless dir.join("pid").exist?
          return :running unless exit_path.exist?

          (exit_path.read.strip == "0") ? :succeeded : :failed
        end

        def running? = state == :running

        def log = log_path.exist? ? log_path.read : ""

        # The versions installed before the last run, or nil when nothing ran.
        def versions_before
          JSON.parse(dir.join("from.json").read) if dir.join("from.json").exist?
        end

        # Puma's tmp_restart plugin, which Rails' generated puma.rb loads, restarts the server when this file is touched.
        def restart
          FileUtils.touch(Rails.root.join("tmp", "restart.txt"))
        end

        private

        def dir = Rails.root.join("tmp", "avo_update")

        def log_path = dir.join("output.log")

        def exit_path = dir.join("exit_status")
      end
    end
  end
end
