require "rails_helper"

RSpec.describe Avo::Services::TelemetryService do
  describe ".avo_metadata" do
    it "merges static structural counts with the runtime probe" do
      structural = {resources_count: 7, fields_count: 42}
      collector = instance_double(described_class::StaticCollector, collect: structural)
      allow(described_class::StaticCollector).to receive(:new).and_return(collector)

      metadata = described_class.avo_metadata

      # Static structural counts pass through untouched.
      expect(metadata).to include(resources_count: 7, fields_count: 42)
      # Runtime-only values are filled in here.
      expect(metadata).to include(
        :main_menu_present, :profile_menu_present, :cache_store, :cache_operational, :plugins, :config
      )
      expect(metadata[:config]).to eq(root_path: Avo.configuration.root_path)
    end

    it "collects statically from the app root" do
      expect(described_class::StaticCollector).to receive(:new)
        .with(Rails.root).and_call_original

      described_class.avo_metadata
    end

    it "produces real structural counts from the dummy app" do
      metadata = described_class.avo_metadata

      expect(metadata[:resources_count]).to be > 0
      expect(metadata[:field_types]).to be_a(Hash)
      expect(metadata[:cache_operational]).to be(true).or be_a(String)
    end
  end

  describe ".install_id" do
    it "is a stable 32-character hex id" do
      id = described_class.install_id

      expect(id).to match(/\A\h{32}\z/)
      expect(described_class.install_id).to eq(id)
    end

    it "changes with the app's secret and contains none of it" do
      app_id = described_class.install_id
      secret = "a1b2c3d4" * 16
      allow(Rails.application).to receive(:key_generator)
        .and_return(ActiveSupport::KeyGenerator.new(secret, iterations: 1000))

      other_id = described_class.install_id

      expect(other_id).to match(/\A\h{32}\z/)
      expect(other_id).not_to eq(app_id)
      expect(secret).not_to include(other_id)
    end

    it "returns nil instead of raising when there is no secret" do
      allow(Rails.application).to receive(:key_generator).and_raise(ArgumentError)

      expect(described_class.install_id).to be_nil
    end
  end

  describe ".cache_operational?" do
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }
    let(:connection_error) { "Error connecting to Redis on 10.0.4.12:6379" }

    before { allow(Avo).to receive(:cache_store).and_return(cache) }

    it "returns true for a working cache and leaves no test key behind" do
      expect(described_class.cache_operational?).to be(true)
      expect(cache.exist?("avo-test-cache")).to be(false)
    end

    it "reports only the exception class when write raises" do
      allow(cache).to receive(:write).and_raise(Errno::ECONNREFUSED, connection_error)

      result = described_class.cache_operational?

      expect(result).to eq("error: Errno::ECONNREFUSED")
      expect(result).not_to include("10.0.4.12")
      expect(result).not_to include("6379")
    end

    it "deletes the test key when read raises after a successful write" do
      allow(cache).to receive(:read).and_raise(RuntimeError, connection_error)

      expect(described_class.cache_operational?).to eq("error: RuntimeError")
      expect(cache.exist?("avo-test-cache")).to be(false)
    end

    it "does not raise when the cleanup delete raises" do
      allow(cache).to receive(:delete).and_raise(RuntimeError, connection_error)

      expect(described_class.cache_operational?).to be(true)
    end
  end

  describe ".plugins_metadata" do
    def plugin_double(gem_name:, name:, version:)
      instance_double(Avo::Plugin, gem_name: gem_name, name: name, version: version)
    end

    it "maps registered plugins to their resolved gem name and version" do
      plugin = plugin_double(gem_name: "avo-kanban", name: "avo-kanban", version: "4.0.0")
      allow(Avo.plugin_manager).to receive(:all).and_return([plugin])

      expect(described_class.plugins_metadata).to eq([{name: "avo-kanban", version: "4.0.0"}])
    end

    it "falls back to the registration name when the gem can't be resolved" do
      plugin = plugin_double(gem_name: nil, name: :rhino, version: nil)
      allow(Avo.plugin_manager).to receive(:all).and_return([plugin])

      expect(described_class.plugins_metadata).to eq([{name: "rhino", version: nil}])
    end

    it "returns an empty array when the plugin manager raises" do
      allow(Avo.plugin_manager).to receive(:all).and_raise("boom")

      expect(described_class.plugins_metadata).to eq([])
    end
  end
end
