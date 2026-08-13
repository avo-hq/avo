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

  describe "register/mount_engine called outside a begin_reload/commit_reload window" do
    # Mirrors a real call pattern: gems/avo-permissions registers its plugin
    # name directly inside a Rails initializer (not inside
    # ActiveSupport.on_load(:avo_boot)), which runs before Avo.boot ever
    # calls #begin_reload for the first time.
    it "does not raise when called on a freshly-initialized manager" do
      expect { manager.register(:avo_permissions, priority: 5) }.not_to raise_error
      expect { manager.mount_engine(engine_a, at: "/a") }.not_to raise_error
    end

    it "discards a pre-begin_reload registration on the next begin_reload, matching pre-atomic-publish behavior" do
      manager.register(:avo_permissions, priority: 5)
      manager.mount_engine(engine_a, at: "/a")

      manager.begin_reload
      manager.commit_reload

      expect(manager.plugins).to eq([])
      expect(manager.engines).to eq([])
    end

    it "does not raise when called again after a commit_reload, between reload cycles" do
      manager.begin_reload
      manager.commit_reload

      expect { manager.register(:late_plugin, priority: 5) }.not_to raise_error
      expect { manager.mount_engine(engine_b, at: "/b") }.not_to raise_error
    end
  end

  describe "#register_configuration" do
    let(:config_class) do
      Class.new do
        attr_accessor :thinking_effort
      end
    end

    after do
      if Avo::Configuration.method_defined?(:my_plugin)
        Avo::Configuration.remove_method(:my_plugin)
        Avo::Configuration.remove_method(:my_plugin=)
      end
    end

    it "defines a memoized namespace accessor on Avo::Configuration" do
      manager.register_configuration :my_plugin, config_class

      configuration = Avo::Configuration.new
      configuration.my_plugin.thinking_effort = "high"

      expect(configuration.my_plugin).to be_a(config_class)
      expect(configuration.my_plugin.thinking_effort).to eq("high")
      expect(configuration.my_plugin).to equal(configuration.my_plugin)
    end

    it "memoizes per Configuration instance, so replacing Avo.configuration resets plugin configs" do
      manager.register_configuration :my_plugin, config_class

      one = Avo::Configuration.new
      two = Avo::Configuration.new

      expect(one.my_plugin).not_to equal(two.my_plugin)
    end

    it "allows assigning a whole configuration object" do
      manager.register_configuration :my_plugin, config_class

      configuration = Avo::Configuration.new
      replacement = config_class.new
      configuration.my_plugin = replacement

      expect(configuration.my_plugin).to equal(replacement)
    end

    it "raises when the namespace would shadow an existing option" do
      expect { manager.register_configuration :appearance, config_class }
        .to raise_error(ArgumentError, /already defines/)
    end

    it "allows a namespace that only collides with a method mixed into every object (e.g. amazing_print's Kernel#ai)" do
      Kernel.module_eval { def my_plugin = nil }

      expect { manager.register_configuration :my_plugin, config_class }.not_to raise_error
      expect(Avo::Configuration.new.my_plugin).to be_a(config_class)
    ensure
      Kernel.module_eval { remove_method :my_plugin }
    end

    it "allows re-registering the same namespace across boots" do
      manager.register_configuration :my_plugin, config_class

      expect { manager.register_configuration :my_plugin, config_class }.not_to raise_error
    end

    it "raises when a different class tries to claim an already-registered namespace" do
      manager.register_configuration :my_plugin, config_class

      other_class = Class.new
      expect { manager.register_configuration :my_plugin, other_class }
        .to raise_error(ArgumentError, /already registered/)
      expect(Avo::Configuration.new.my_plugin).to be_a(config_class)
    end
  end
end
