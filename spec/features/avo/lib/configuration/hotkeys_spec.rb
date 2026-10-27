require "rails_helper"

RSpec.describe Avo::Configuration, "#hotkeys" do
  let(:config) { described_class.new }

  describe "defaults" do
    it "returns enabled: true, show_key_badges: true when never set" do
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: true, bindings: {}})
    end
  end

  describe "partial overrides" do
    it "merges enabled: false with defaults" do
      config.hotkeys = {enabled: false}
      expect(config.hotkeys).to eq({enabled: false, show_key_badges: true, bindings: {}})
    end

    it "merges show_key_badges: false with defaults" do
      config.hotkeys = {show_key_badges: false}
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: false, bindings: {}})
    end
  end

  describe "empty hash" do
    it "returns full defaults" do
      config.hotkeys = {}
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: true, bindings: {}})
    end
  end

  describe "bindings" do
    around do |example|
      original = Avo.configuration.hotkeys
      example.run
      Avo.configuration.hotkeys = original
    end

    def bind(bindings)
      Avo.configuration.hotkeys = {bindings:}
    end

    it "rebinds a shortcut by ID and leaves the others on their defaults" do
      bind("record.edit": "Shift+E")

      expect(Avo::Hotkeys.key_for("record.edit")).to eq("Shift+E")
      expect(Avo::Hotkeys.key_for("record.delete")).to eq("d")
    end

    it "disables a shortcut bound to false" do
      bind("record.delete": false)

      expect(Avo::Hotkeys.key_for("record.delete")).to be_nil
      expect { Avo::Hotkeys.validate! }.not_to raise_error
    end

    it "raises on a typo in a known namespace" do
      bind("record.edti": "x")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /Unknown hotkey "record.edti"/)
    end

    it "ignores bindings for a plugin that isn't installed" do
      bind("not_installed.open": "x")

      expect { Avo::Hotkeys.validate! }.not_to raise_error
    end

    it "raises when two shortcuts that can fire on the same page share a key" do
      bind("record.edit": "j")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /"record.edit" and "index.next_row" conflict/)
    end

    it "allows the same key on views that never render together" do
      bind("resource.go_to_index": "/")

      expect { Avo::Hotkeys.validate! }.not_to raise_error
    end

    it "raises when a single key would swallow a sequence" do
      bind("record.edit": "v")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /v blocks the sequence v t/)
    end

    it "compares modifiers regardless of the order they are written in" do
      bind("record.edit": "Shift+Mod+e", "record.delete": "Mod+Shift+e")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /conflict/)
    end

    it "refuses an explicit Meta+Enter, which is Mod+Enter on macOS" do
      bind("resource.actions": "Meta+Enter")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /reserved/)
    end

    it "refuses the locked Escape and Mod+Enter keys" do
      bind("record.edit": "j,Escape")

      expect { Avo::Hotkeys.validate! }.to raise_error(ArgumentError, /reserved/)
    end
  end

  describe "plugin hotkeys" do
    it "namespaces a plugin's hotkeys by its gem name" do
      plugin = Avo::Plugin.new(name: "avo-dynamic_filters", priority: 10)
      plugin.register_hotkey(:open, default: "f", label: "Open filters", section: "Index view")

      expect(plugin.hotkeys.map(&:id)).to eq(["dynamic_filters.open"])
    end

    it "refuses a plugin whose name collides with a core namespace" do
      plugin = Avo::Plugin.new(name: "avo-record", priority: 10)

      expect { plugin.register_hotkey(:open, default: "f", label: "Open", section: "Navigation") }
        .to raise_error(ArgumentError, /"record" is a core hotkey namespace/)
    end
  end
end
