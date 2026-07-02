#
# Feature specs are run via `parallel_rspec` (multiple OS processes).
# Ruby primitives like `Mutex`/`Monitor` only synchronize threads *within one process*,
# so they can't prevent cross-process filesystem races (e.g. generators creating/deleting
# files while other processes are booting Rails/Zeitwerk). `File#flock` is process-wide.
#
# How it's used:
# - By default, all `type: :feature` specs take a shared lock so they can run in parallel.
# - Specs tagged with `acquire_lock: :generator` (or another key) take an exclusive lock to
#   serialize specs that mutate global state (mostly filesystem changes) and would otherwise leak
#   state across processes and cause intermittent Zeitwerk/load issues.
#
RSpec.configure do |config|
  config.around(:each, type: :feature) do |example|
    require "tmpdir"
    global_lock_path = File.join(Dir.tmpdir, "avo-feature-specs.fs.lock")
    lock_key = example.metadata[:acquire_lock]
    key_lock_path = lock_key ? File.join(Dir.tmpdir, "avo-feature-specs.#{lock_key}.lock") : nil

    File.open(global_lock_path, File::RDWR | File::CREAT, 0o644) do |global_lock|
      global_lock.flock(lock_key ? File::LOCK_EX : File::LOCK_SH)

      begin
        if key_lock_path
          File.open(key_lock_path, File::RDWR | File::CREAT, 0o644) do |key_lock|
            key_lock.flock(File::LOCK_EX)
            example.run
          ensure
            key_lock.flock(File::LOCK_UN)
          end
        else
          example.run
        end
      ensure
        global_lock.flock(File::LOCK_UN)
      end
    end
  end
end
