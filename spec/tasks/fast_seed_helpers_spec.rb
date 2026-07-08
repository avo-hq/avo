# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("lib/tasks/support/fast_seed_helpers")

RSpec.describe FastSeedHelpers do
  describe "paths" do
    it "places the committed cache under spec/dummy/db/" do
      expect(described_class.cache_dir.to_s).to end_with("spec/dummy/db/fast_seed")
    end

    it "places the rebuild staging dir under tmp/ so half-written caches never get committed" do
      expect(described_class.tmp_cache_dir.to_s).to end_with("spec/dummy/tmp/fast_seed.tmp")
    end

    it "derives the live storage dir from the active Active Storage service root" do
      # In the test environment the active service is `:test` rooted at tmp/storage.
      expect(described_class.live_storage_dir.to_s).to end_with("tmp/storage")
    end

    it "derives child paths off a cache directory" do
      dir = Pathname.new("/tmp/example")
      expect(described_class.dump_path(dir).to_s).to eq("/tmp/example/data.sql")
      expect(described_class.storage_snapshot_path(dir).to_s).to eq("/tmp/example/storage")
    end
  end

  describe ".check_postgres_binaries!" do
    it "returns nil when all binaries are available" do
      allow(described_class).to receive(:binary_available?).and_return(true)
      expect { described_class.check_postgres_binaries! }.not_to raise_error
    end

    it "aborts with a message naming each missing binary" do
      allow(described_class).to receive(:binary_available?) do |bin|
        bin == "psql"
      end
      expect { described_class.check_postgres_binaries! }
        .to raise_error(SystemExit, /pg_dump, pg_restore/)
    end

    it "includes install hints in the abort message" do
      allow(described_class).to receive(:binary_available?).and_return(false)
      expect { described_class.check_postgres_binaries! }
        .to raise_error(SystemExit, /brew install libpq/)
    end
  end

  describe ".check_disk_storage_service!" do
    it "returns nil when the active service is a DiskService" do
      service = instance_double(ActiveStorage::Service::DiskService)
      allow(service).to receive(:is_a?).with(ActiveStorage::Service::DiskService).and_return(true)
      allow(ActiveStorage::Blob).to receive(:service).and_return(service)

      expect { described_class.check_disk_storage_service! }.not_to raise_error
    end

    it "aborts with a message mentioning STORAGE_SERVICE when the service is not Disk" do
      fake_service = Class.new do
        def self.name = "ActiveStorage::Service::S3Service"
      end.new
      allow(ActiveStorage::Blob).to receive(:service).and_return(fake_service)

      expect { described_class.check_disk_storage_service! }
        .to raise_error(SystemExit, /STORAGE_SERVICE/)
    end
  end

  describe ".libpq_env" do
    it "maps the AR connection config to PG* env vars" do
      config = instance_double(
        ActiveRecord::DatabaseConfigurations::HashConfig,
        configuration_hash: {host: "localhost", port: 5432, username: "postgres", password: nil}
      )
      allow(ActiveRecord::Base).to receive(:connection_db_config).and_return(config)

      env = described_class.libpq_env

      expect(env).to include("PGHOST" => "localhost", "PGPORT" => "5432", "PGUSER" => "postgres")
      expect(env).not_to have_key("PGPASSWORD")
    end
  end

  describe ".filter_dump_text" do
    it "strips SET commands for GUCs older Postgres versions don't recognize" do
      dump = <<~SQL
        SET statement_timeout = 0;
        SET transaction_timeout = 0;
        SET client_encoding = 'UTF8';
        COPY users (id, email) FROM stdin;
        1\thi@avohq.io
        \\.
      SQL

      out = described_class.filter_dump_text(dump)

      expect(out).not_to include("SET transaction_timeout")
      expect(out).to include("SET statement_timeout = 0;")
      expect(out).to include("COPY users")
    end

    it "prepends `session_replication_role = replica` to disable triggers and FK checks during load" do
      out = described_class.filter_dump_text("SELECT 1;\n")
      expect(out.lines.first).to eq("SET session_replication_role = replica;\n")
    end
  end

  describe ".binary_available?" do
    it "returns true for a binary on PATH" do
      expect(described_class.binary_available?("ruby")).to be(true)
    end

    it "returns false for a non-existent binary" do
      expect(described_class.binary_available?("definitely-not-a-real-binary-xyz")).to be(false)
    end
  end

  describe ".snapshot_storage and .restore_storage_snapshot" do
    let(:tmpdir) { Pathname.new(Dir.mktmpdir("fast_seed_helpers_spec")) }
    let(:fake_live) { tmpdir.join("live_storage") }
    let(:fake_cache) { tmpdir.join("cache") }

    before do
      FileUtils.mkdir_p(fake_live.join("ab"))
      File.write(fake_live.join("ab/blob1"), "blob-one")
      File.write(fake_live.join("top.txt"), "top-level")
      allow(described_class).to receive(:live_storage_dir).and_return(fake_live)
      FileUtils.mkdir_p(fake_cache)
    end

    after { FileUtils.rm_rf(tmpdir) }

    it "snapshots the entire storage tree into the cache" do
      described_class.snapshot_storage(fake_cache)

      snapshot = fake_cache.join("storage")
      expect(snapshot.join("ab/blob1").read).to eq("blob-one")
      expect(snapshot.join("top.txt").read).to eq("top-level")
    end

    it "restores by clearing live storage and copying the snapshot back" do
      described_class.snapshot_storage(fake_cache)

      # Mutate live storage; restore should put it back as it was.
      File.write(fake_live.join("top.txt"), "mutated")
      FileUtils.rm_rf(fake_live.join("ab"))
      FileUtils.touch(fake_live.join(".keep"))

      described_class.restore_storage_snapshot(fake_cache)

      expect(fake_live.join("top.txt").read).to eq("top-level")
      expect(fake_live.join("ab/blob1").read).to eq("blob-one")
      expect(fake_live.join(".keep")).to exist
    end
  end
end
