# frozen_string_literal: true

# `db:fast_seed` / `db:fast_seed:rebuild` -- developer-only fast seeding for the
# Avo dummy app. See docs/plans/2026-05-22-001-feat-fast-seeder-plan.md.

require "open3"
require_relative "support/fast_seed_helpers"

namespace :db do
  desc "Restore the dummy DB from the cached fast-seed dump and storage snapshot"
  task fast_seed: :environment do
    started_at = Time.now
    cache_dir = FastSeedHelpers.cache_dir
    dump_file = FastSeedHelpers.dump_path(cache_dir)

    FastSeedHelpers.check_postgres_binaries!
    FastSeedHelpers.check_disk_storage_service!

    unless File.exist?(dump_file)
      abort "No fast-seed cache found at #{cache_dir}/. " \
            "Run `bin/rails app:db:fast_seed:rebuild` to generate one (takes ~10s)."
    end

    db_name = FastSeedHelpers.current_db_name
    puts "[fast_seed] Restoring #{db_name} from #{cache_dir.basename}/"

    FastSeedHelpers.prepare_fresh_database!

    psql_cmd = [
      "psql",
      "--single-transaction",
      "--quiet",
      "-v", "ON_ERROR_STOP=1",
      "-d", db_name,
      "-f", dump_file.to_s
    ]
    begin
      system(FastSeedHelpers.libpq_env, *psql_cmd, exception: true)
    rescue => e
      abort "psql restore failed (#{e.message}). " \
            "If you recently pulled new migrations, the cache is stale -- run `bin/rails app:db:fast_seed:rebuild`."
    end

    FastSeedHelpers.restore_storage_snapshot(cache_dir)

    elapsed = (Time.now - started_at).round(2)
    puts "[fast_seed] Done in #{elapsed}s"
  end

  namespace :fast_seed do
    desc "Regenerate the fast-seed cache by running spec/dummy/db/seeds.rb end-to-end"
    task rebuild: :environment do
      started_at = Time.now
      cache_dir = FastSeedHelpers.cache_dir
      tmp_cache = FastSeedHelpers.tmp_cache_dir

      FastSeedHelpers.check_postgres_binaries!
      FastSeedHelpers.check_disk_storage_service!

      db_name = FastSeedHelpers.current_db_name
      puts "[fast_seed:rebuild] Rebuilding cache for #{db_name}"

      # Prep an empty staging dir.
      FileUtils.rm_rf(tmp_cache)
      FileUtils.mkdir_p(tmp_cache)

      FastSeedHelpers.prepare_fresh_database!

      # Clear any orphaned blobs left over from previous rebuilds or manual dev work,
      # otherwise the snapshot would accumulate every blob ever created in this workspace.
      FastSeedHelpers.clear_live_storage!

      puts "[fast_seed:rebuild] Running seeds.rb"
      load Rails.root.join("db", "seeds.rb")

      puts "[fast_seed:rebuild] Dumping data"
      pg_dump_cmd = [
        "pg_dump",
        "--data-only",
        "--no-owner",
        # These two are populated by db:schema:load, so re-COPY-ing them would
        # collide on the primary key during restore.
        "--exclude-table=schema_migrations",
        "--exclude-table=ar_internal_metadata",
        "-d", db_name
      ]
      dump_text, status = Open3.capture2(FastSeedHelpers.libpq_env, *pg_dump_cmd)
      unless status.success?
        abort "[fast_seed:rebuild] pg_dump failed (exit #{status.exitstatus})"
      end
      File.write(
        FastSeedHelpers.dump_path(tmp_cache),
        FastSeedHelpers.filter_dump_text(dump_text)
      )

      puts "[fast_seed:rebuild] Snapshotting storage/"
      FastSeedHelpers.snapshot_storage(tmp_cache)

      puts "[fast_seed:rebuild] Atomically swapping cache into place"
      FastSeedHelpers.swap_cache_atomically!(tmp_cache, cache_dir)

      elapsed = (Time.now - started_at).round(2)
      puts "[fast_seed:rebuild] Done in #{elapsed}s. Cache at #{cache_dir}"
    end
  end
end
