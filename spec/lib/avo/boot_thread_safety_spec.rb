require "rails_helper"

RSpec.describe "Avo.boot thread safety" do
  include_context "with isolated plugin manager"

  it "populates plugin_manager as before for a normal single-threaded boot" do
    fake_engine = Class.new(Rails::Engine)
    allow(ActiveSupport).to receive(:run_load_hooks).and_call_original
    allow(ActiveSupport).to receive(:run_load_hooks).with(:avo_boot, Avo) do
      Avo.plugin_manager.register(:fake_plugin, priority: 5)
      Avo.plugin_manager.mount_engine(fake_engine, at: "/fake")
    end

    Avo.boot

    expect(Avo.plugin_manager.engines).to eq([{klass: fake_engine, options: {at: "/fake"}}])
    expect(Avo.plugin_manager.plugins.map(&:name)).to eq([:fake_plugin])
  end

  it "leaves no duplicate engines or plugins when multiple threads call Avo.boot concurrently" do
    fake_engine = Class.new(Rails::Engine)
    allow(ActiveSupport).to receive(:run_load_hooks).and_call_original
    allow(ActiveSupport).to receive(:run_load_hooks).with(:avo_boot, Avo) do
      # Widen the interleaving window so, without the fix, concurrent boots
      # reliably interleave their reset-then-repopulate sequence instead of
      # relying on timing luck.
      Avo.plugin_manager.register(:fake_plugin, priority: 5)
      Thread.pass
      Avo.plugin_manager.mount_engine(fake_engine, at: "/fake")
      Thread.pass
    end

    threads = 8.times.map { Thread.new { Avo.boot } }
    threads.each(&:join)

    expect(Avo.plugin_manager.engines).to eq([{klass: fake_engine, options: {at: "/fake"}}])
    expect(Avo.plugin_manager.plugins.map(&:name)).to eq([:fake_plugin])
  end

  it "never exposes a partially rebuilt engines list to a concurrent reader" do
    fake_engine_1 = Class.new(Rails::Engine)
    fake_engine_2 = Class.new(Rails::Engine)
    reached_midpoint = Queue.new
    release_midpoint = Queue.new

    allow(ActiveSupport).to receive(:run_load_hooks).and_call_original
    allow(ActiveSupport).to receive(:run_load_hooks).with(:avo_boot, Avo) do
      Avo.plugin_manager.mount_engine(fake_engine_1, at: "/one")
      reached_midpoint << true
      release_midpoint.pop
      Avo.plugin_manager.mount_engine(fake_engine_2, at: "/two")
    end

    pre_boot_engines = Avo.plugin_manager.engines

    boot_thread = Thread.new { Avo.boot }
    reached_midpoint.pop # wait until the background boot has registered engine 1 but not committed

    begin
      # Mid-boot, a concurrent reader (standing in for mount_avo's route-drawing
      # loop) must see the complete pre-boot list, never a partial one that
      # contains only fake_engine_1.
      expect(Avo.plugin_manager.engines).to eq(pre_boot_engines)
    ensure
      # Always release the paused background thread, even if the assertion
      # above fails -- otherwise boot_thread stays parked mid-Avo.boot,
      # permanently holding the boot mutex and hanging every later spec in
      # this process that calls Avo.boot.
      release_midpoint << true
      boot_thread.join
    end

    expect(Avo.plugin_manager.engines).to eq([
      {klass: fake_engine_1, options: {at: "/one"}},
      {klass: fake_engine_2, options: {at: "/two"}}
    ])
  end

  it "does not deadlock when Avo.boot is called sequentially, matching the two real call sites" do
    allow(ActiveSupport).to receive(:run_load_hooks).and_call_original

    expect {
      Avo.boot
      Avo.boot
    }.not_to raise_error
  end
end
