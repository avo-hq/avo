# frozen_string_literal: true

require "rails_helper"
require "rake"
require Rails.root.join("lib/tasks/support/fast_seed_helpers")

# Smoke tests for db:fast_seed / db:fast_seed:rebuild.
#
# These do NOT exercise the destructive drop/create/dump pipeline -- the real
# verification is `bin/rails db:fast_seed:rebuild` followed by `bin/rails db:fast_seed`
# on the implementer's machine. These specs cover the safe paths: preflight,
# task discovery, and the missing-cache abort.
RSpec.describe "db:fast_seed rake tasks" do
  before(:all) do
    unless Rake::Task.task_defined?("db:fast_seed")
      Rake.application.rake_require("fast_seed", [Rails.root.join("lib/tasks").to_s])
    end
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
  end

  before(:each) do
    %w[db:fast_seed db:fast_seed:rebuild].each do |name|
      Rake::Task[name].reenable if Rake::Task.task_defined?(name)
    end
  end

  describe "db:fast_seed" do
    it "is defined" do
      expect(Rake::Task.task_defined?("db:fast_seed")).to be(true)
    end

    it "aborts with the R3 message when the cache is missing" do
      allow(FastSeedHelpers).to receive(:check_postgres_binaries!)
      allow(FastSeedHelpers).to receive(:check_disk_storage_service!)
      allow(FastSeedHelpers).to receive(:cache_dir).and_return(
        Pathname.new(Dir.mktmpdir("fast_seed_missing"))
      )

      expect { Rake::Task["db:fast_seed"].invoke }
        .to raise_error(SystemExit, /No fast-seed cache found.*db:fast_seed:rebuild/m)
    end

    it "runs the binary preflight before touching anything else" do
      allow(FastSeedHelpers).to receive(:check_postgres_binaries!).and_raise(SystemExit.new("missing pg_dump"))
      expect(FastSeedHelpers).not_to receive(:terminate_backends!)

      expect { Rake::Task["db:fast_seed"].invoke }.to raise_error(SystemExit, /missing pg_dump/)
    end
  end

  describe "db:fast_seed:rebuild" do
    it "is defined" do
      expect(Rake::Task.task_defined?("db:fast_seed:rebuild")).to be(true)
    end

    it "runs preflight checks before any destructive action" do
      allow(FastSeedHelpers).to receive(:check_postgres_binaries!).and_raise(SystemExit.new("missing"))
      expect(FastSeedHelpers).not_to receive(:terminate_backends!)
      expect(Rake::Task["db:drop"]).not_to receive(:invoke) if Rake::Task.task_defined?("db:drop")

      expect { Rake::Task["db:fast_seed:rebuild"].invoke }.to raise_error(SystemExit, /missing/)
    end

    it "aborts on non-Disk active storage services" do
      allow(FastSeedHelpers).to receive(:check_postgres_binaries!)
      allow(FastSeedHelpers).to receive(:check_disk_storage_service!).and_raise(SystemExit.new("not disk"))

      expect { Rake::Task["db:fast_seed:rebuild"].invoke }.to raise_error(SystemExit, /not disk/)
    end
  end
end
