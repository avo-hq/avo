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
      expect(metadata[:config]).to include(:root_path, :app_name)
    end

    it "collects statically from the app's app/avo directory" do
      expect(described_class::StaticCollector).to receive(:new)
        .with(Rails.root.join("app", "avo")).and_call_original

      described_class.avo_metadata
    end

    it "produces real structural counts from the dummy app" do
      metadata = described_class.avo_metadata

      expect(metadata[:resources_count]).to be > 0
      expect(metadata[:field_types]).to be_a(Hash)
      expect(metadata[:cache_operational]).to be(true).or be_a(String)
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
