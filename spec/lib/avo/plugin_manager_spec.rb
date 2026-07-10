require "rails_helper"

RSpec.describe Avo::PluginManager do
  subject(:manager) { described_class.new }

  let(:engine_a) { Class.new(Rails::Engine) }
  let(:engine_b) { Class.new(Rails::Engine) }

  describe "#mount_engine" do
    context "happy path" do
      it "appends exactly one entry with the given options after a reload cycle" do
        manager.begin_reload
        manager.mount_engine(engine_a, at: "/a")
        manager.commit_reload

        expect(manager.engines).to eq([{klass: engine_a, options: {at: "/a"}}])
      end
    end

    context "duplicate call for the same class" do
      it "leaves exactly one entry reflecting the most recent options" do
        manager.begin_reload
        manager.mount_engine(engine_a, at: "/old")
        manager.mount_engine(engine_a, at: "/new")
        manager.commit_reload

        expect(manager.engines).to eq([{klass: engine_a, options: {at: "/new"}}])
      end
    end

    context "distinct classes" do
      it "appends two distinct entries in insertion order" do
        manager.begin_reload
        manager.mount_engine(engine_a, at: "/a")
        manager.mount_engine(engine_b, at: "/b")
        manager.commit_reload

        expect(manager.engines).to eq([
          {klass: engine_a, options: {at: "/a"}},
          {klass: engine_b, options: {at: "/b"}}
        ])
      end
    end
  end

  describe "reader isolation before #commit_reload" do
    it "does not change .engines or .plugins until commit_reload publishes them" do
      manager.begin_reload
      manager.mount_engine(engine_a, at: "/a")
      manager.register(:some_plugin, priority: 5)

      expect(manager.engines).to eq([])
      expect(manager.plugins).to eq([])

      manager.commit_reload

      expect(manager.engines).to eq([{klass: engine_a, options: {at: "/a"}}])
      expect(manager.plugins.map(&:name)).to eq([:some_plugin])
    end

    it "preserves a previously published list across a new begin_reload until commit_reload" do
      manager.begin_reload
      manager.mount_engine(engine_a, at: "/a")
      manager.commit_reload

      manager.begin_reload
      manager.mount_engine(engine_b, at: "/b")

      expect(manager.engines).to eq([{klass: engine_a, options: {at: "/a"}}])

      manager.commit_reload

      expect(manager.engines).to eq([{klass: engine_b, options: {at: "/b"}}])
    end
  end

  describe "#reset" do
    it "clears both plugins and engines directly, independent of begin_reload/commit_reload" do
      manager.begin_reload
      manager.mount_engine(engine_a, at: "/a")
      manager.commit_reload
      expect(manager.engines).not_to be_empty

      manager.reset

      expect(manager.engines).to eq([])
      expect(manager.plugins).to eq([])
    end
  end
end
