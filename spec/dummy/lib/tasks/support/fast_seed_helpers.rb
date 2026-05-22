# frozen_string_literal: true

require "fileutils"
require "open3"

# Shared helpers for the `db:fast_seed` and `db:fast_seed:rebuild` rake tasks.
# See docs/plans/2026-05-22-001-feat-fast-seeder-plan.md for context.
module FastSeedHelpers
  module_function

  REQUIRED_BINARIES = %w[pg_dump pg_restore psql].freeze

  # The committed cache. Lives under db/ (not tmp/) so a fresh clone can run
  # `bin/rails app:db:fast_seed` without first running rebuild.
  def cache_dir
    Rails.root.join("db/fast_seed")
  end

  # Where rebuild writes before the atomic swap into cache_dir. Under tmp/
  # so a half-written rebuild never pollutes git.
  def tmp_cache_dir
    Rails.root.join("tmp/fast_seed.tmp")
  end

  def dump_path(dir)
    dir.join("data.sql")
  end

  # SET commands that newer pg_dump versions emit but older servers don't recognize.
  # Filter these out so a libpq-17 client can dump from and restore to a < 17 server.
  INCOMPATIBLE_SETS = /\ASET\s+(transaction_timeout)\b/

  # Wrap the dump body so trigger/FK firing is disabled during the data load.
  # `session_replication_role = replica` makes triggers (including FK triggers)
  # behave as if running in a logical replica — they don't fire. Requires
  # SUPERUSER, the same privilege requirement we had with pg_restore --disable-triggers.
  DUMP_PREAMBLE = "SET session_replication_role = replica;\n"

  def filter_dump_text(text)
    body = text.each_line.reject { |line| line =~ INCOMPATIBLE_SETS }.join
    DUMP_PREAMBLE + body
  end

  def storage_snapshot_path(dir)
    dir.join("storage")
  end

  # The actual on-disk root for the configured Active Storage disk service.
  # Honors STORAGE_SERVICE overrides (e.g. `:test` uses Rails.root/tmp/storage).
  def live_storage_dir
    service = ActiveStorage::Blob.service
    Pathname.new(service.root)
  end

  def check_postgres_binaries!
    missing = REQUIRED_BINARIES.reject { |bin| binary_available?(bin) }
    return if missing.empty?

    abort <<~MSG.chomp
      [fast_seed] Missing Postgres CLI binaries: #{missing.join(", ")}.

      db:fast_seed and db:fast_seed:rebuild need pg_dump, pg_restore, and psql on PATH.

      Install hints:
        macOS (Homebrew):  brew install libpq && brew link --force libpq
        Debian/Ubuntu:     sudo apt install postgresql-client
        Fedora:            sudo dnf install postgresql

      After installing, open a new shell or `hash -r` so PATH is refreshed.
    MSG
  end

  def check_disk_storage_service!
    service = ActiveStorage::Blob.service
    return if service.is_a?(ActiveStorage::Service::DiskService)

    abort <<~MSG.chomp
      [fast_seed] Active Storage service is `#{service.class.name.split("::").last}`, not Disk.

      db:fast_seed and db:fast_seed:rebuild snapshot and restore the local storage/ directory,
      which only works with the Disk service.

      Likely cause: STORAGE_SERVICE env var is overriding the default. Try:
        unset STORAGE_SERVICE
    MSG
  end

  def terminate_backends!(database_name)
    pool = ActiveRecord::Base.connection_pool
    pool.disconnect! if pool.connected?

    conn = PG.connect(admin_connection_params)
    conn.exec_params(
      "SELECT pg_terminate_backend(pid) FROM pg_stat_activity " \
      "WHERE datname = $1 AND pid <> pg_backend_pid()",
      [database_name]
    )
  rescue PG::Error => e
    # Tolerate first-run case where neither the dummy DB nor a `postgres` admin DB exists yet --
    # `db:drop`/`db:create` will surface a clearer error if there's a real problem.
    warn "[fast_seed] terminate_backends! skipped (#{e.message.strip})"
  ensure
    conn&.close
  end

  def current_db_name
    ActiveRecord::Base.connection_db_config.database
  end

  def libpq_env
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    env = {
      "PGHOST" => config[:host],
      "PGPORT" => config[:port]&.to_s,
      "PGUSER" => config[:username],
      "PGPASSWORD" => config[:password]
    }
    env.compact.transform_values(&:to_s)
  end

  def binary_available?(name)
    _stdout, status = Open3.capture2("which", name)
    status.success?
  rescue Errno::ENOENT
    false
  end

  def admin_connection_params
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    {
      host: config[:host],
      port: config[:port],
      user: config[:username],
      password: config[:password],
      dbname: "postgres"
    }.compact
  end

  # Copy the live `storage/` dir contents into `<dest_cache>/storage/`.
  def snapshot_storage(dest_cache)
    storage_dest = storage_snapshot_path(dest_cache)
    FileUtils.mkdir_p(storage_dest)
    return unless Dir.exist?(live_storage_dir)

    Dir.children(live_storage_dir).each do |entry|
      FileUtils.cp_r(live_storage_dir.join(entry), storage_dest.join(entry))
    end
  end

  # Empty the live storage dir so a fresh rebuild's snapshot contains only
  # what the current seeder writes (no orphaned blobs from past rebuilds or
  # manual dev uploads). Preserves `.keep`.
  def clear_live_storage!
    return unless Dir.exist?(live_storage_dir)

    Dir.children(live_storage_dir).each do |entry|
      next if entry == ".keep"
      FileUtils.rm_rf(live_storage_dir.join(entry))
    end
  end

  # Replace the live `storage/` dir contents with the snapshot under `<source_cache>/storage/`.
  # Preserves `.keep` if present.
  def restore_storage_snapshot(source_cache)
    snapshot = storage_snapshot_path(source_cache)
    FileUtils.mkdir_p(live_storage_dir)

    Dir.children(live_storage_dir).each do |entry|
      next if entry == ".keep"
      FileUtils.rm_rf(live_storage_dir.join(entry))
    end

    return unless Dir.exist?(snapshot)

    Dir.children(snapshot).each do |entry|
      FileUtils.cp_r(snapshot.join(entry), live_storage_dir.join(entry))
    end
  end

  # Drop the current DB (terminating active backends first), recreate, and load schema.
  # Tolerates `db:drop` racing against a slow backend drain by retrying once.
  # Bypasses ActiveRecord's `check_protected_environments` -- a drop-and-recreate
  # dev tool is exactly the case that flag exists for.
  def prepare_fresh_database!
    db_name = current_db_name
    terminate_backends!(db_name)

    prior_env_check = ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"]
    ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = "1"

    attempts = 0
    begin
      Rake::Task["db:drop"].invoke
      Rake::Task["db:drop"].reenable
    rescue => e
      attempts += 1
      if attempts <= 1 && e.message.match?(/being accessed by other users/i)
        warn "[fast_seed] db:drop saw lingering connections; terminating again and retrying"
        terminate_backends!(db_name)
        sleep 0.25
        retry
      end
      raise
    end

    Rake::Task["db:create"].invoke
    Rake::Task["db:create"].reenable
    Rake::Task["db:schema:load"].invoke
    Rake::Task["db:schema:load"].reenable
  ensure
    ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = prior_env_check
  end

  # Two-step rename so the live cache_dir is never absent: move the prior cache
  # aside (into tmp/, so the side-copy is always gitignored even when cache_dir
  # is committed under db/), move the new one into place, then delete the aside.
  def swap_cache_atomically!(tmp_cache, cache_dir)
    aside = Rails.root.join("tmp/fast_seed.old")
    FileUtils.rm_rf(aside)
    FileUtils.mv(cache_dir, aside) if cache_dir.exist?
    FileUtils.mv(tmp_cache, cache_dir)
    FileUtils.rm_rf(aside)
  end
end
