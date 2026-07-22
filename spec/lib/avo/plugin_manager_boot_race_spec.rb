require "rails_helper"

RSpec.describe "Avo plugin manager boot race - end-to-end regression" do
  include_context "with isolated plugin manager"

  def stub_pro_engine
    stub_const("Avo::PluginManagerBootRaceSpec", Module.new)
    stub_const("Avo::PluginManagerBootRaceSpec::Engine", Class.new(Rails::Engine) do
      isolate_namespace Avo::PluginManagerBootRaceSpec

      def self.name
        "Avo::PluginManagerBootRaceSpec::Engine"
      end
    end)
    Avo::PluginManagerBootRaceSpec::Engine
  end

  it "does not raise ArgumentError after concurrent Avo.boot calls followed by a route redraw" do
    fake_engine = stub_pro_engine

    allow(ActiveSupport).to receive(:run_load_hooks).and_call_original
    allow(ActiveSupport).to receive(:run_load_hooks).with(:avo_boot, Avo) do
      Avo.plugin_manager.mount_engine(fake_engine, at: "/plugin_manager_boot_race_spec")
    end

    threads = 8.times.map { Thread.new { Avo.boot } }
    threads.each(&:join)

    expect(Avo.plugin_manager.engines).to eq([{klass: fake_engine, options: {at: "/plugin_manager_boot_race_spec"}}])
    expect { draw_mount_avo }.not_to raise_error
  end

  it "sanity check: mount_avo does raise ArgumentError when the registry actually holds a duplicate" do
    # Proves the assertion above is a real regression guard, not vacuously
    # green -- a corrupted registry (the pre-fix failure mode) still trips
    # mount_avo's route-drawing loop.
    fake_engine = stub_pro_engine

    Avo.plugin_manager.begin_reload
    Avo.plugin_manager.instance_variable_get(:@building_engines) << {klass: fake_engine, options: {at: "/one"}}
    Avo.plugin_manager.instance_variable_get(:@building_engines) << {klass: fake_engine, options: {at: "/two"}}
    Avo.plugin_manager.commit_reload

    expect { draw_mount_avo }.to raise_error(ArgumentError, /Invalid route name, already in use/)
  end
end
