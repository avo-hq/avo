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
          # Held until the pid is written, so a double submit can't start a second bundle update on the same lockfile.
          File.open(dir.sub_ext(".lock"), File::CREAT | File::RDWR) do |lock|
            lock.flock(File::LOCK_EX)
            return false if running?

            FileUtils.rm_rf(dir)
            FileUtils.mkdir_p(dir)

            # The shell records the exit status, which a detached child's parent can't collect.
            pid = Bundler.with_original_env do
              Process.spawn(
                "sh", "-c", 'bin/rails avo:update > "$1" 2>&1; echo $? > "$2"', "sh", log_path.to_s, exit_path.to_s,
                chdir: Rails.root.to_s, pgroup: true
              )
            end
            Process.detach(pid)
            File.write(dir.join("pid"), pid)
          end
          true
        end

        # :idle, :running, :succeeded or :failed
        def state
          return :idle unless dir.join("pid").exist?

          # Checked before the exit status: a run that ends between the two reads still reports how it ended.
          alive = process_alive?
          return alive ? :running : :failed unless exit_path.exist?

          (exit_path.read.strip == "0") ? :succeeded : :failed
        end

        def running? = state == :running

        def log = log_path.exist? ? log_path.read : ""

        # Puma's tmp_restart plugin, which Rails' generated puma.rb loads, restarts the server when this file is touched.
        def restart
          FileUtils.rm_rf(dir)
          FileUtils.touch(Rails.root.join("tmp", "restart.txt"))
        end

        private

        def process_alive?
          Process.getpgid(dir.join("pid").read.to_i)
          true
        rescue Errno::ESRCH
          false
        end

        def dir = Rails.root.join("tmp", "avo_update")

        def log_path = dir.join("output.log")

        def exit_path = dir.join("exit_status")
      end
    end
  end
end
