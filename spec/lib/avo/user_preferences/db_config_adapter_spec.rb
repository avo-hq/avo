require "rails_helper"

RSpec.describe Avo::UserPreferences::DBConfigAdapter do
  let(:user) { double("user", id: 42) }
  let(:request) { double("request") }

  describe "#initialize" do
    context "when DBConfig is defined" do
      before do
        stub_const("DBConfig", Class.new)
      end

      it "creates an adapter with default key prefix" do
        adapter = described_class.new
        expect(adapter).to be_a(described_class)
      end

      it "accepts a custom key prefix" do
        adapter = described_class.new(key_prefix: "my_app_prefs")
        expect(adapter).to be_a(described_class)
      end
    end

    context "when DBConfig is not defined" do
      before do
        hide_const("DBConfig") if defined?(DBConfig)
      end

      it "raises Avo::ConfigurationError" do
        expect { described_class.new }.to raise_error(Avo::ConfigurationError, /db_config/i)
      end
    end
  end

  describe "#load" do
    before do
      stub_const("DBConfig", Class.new do
        def self.get(key)
          nil
        end

        def self.set(key, value)
        end
      end)
    end

    let(:adapter) { described_class.new }

    it "returns a hash of preferences" do
      stored = {color_scheme: "dark", theme: "slate"}
      allow(DBConfig).to receive(:get).with("avo_preferences_42").and_return(stored)

      result = adapter.load(user: user, request: request)
      expect(result).to eq(stored)
    end

    it "returns an empty hash when no preferences are stored" do
      allow(DBConfig).to receive(:get).with("avo_preferences_42").and_return(nil)

      result = adapter.load(user: user, request: request)
      expect(result).to eq({})
    end

    it "uses the custom key prefix" do
      adapter = described_class.new(key_prefix: "my_prefs")
      allow(DBConfig).to receive(:get).with("my_prefs_42").and_return({})

      adapter.load(user: user, request: request)
      expect(DBConfig).to have_received(:get).with("my_prefs_42")
    end
  end

  describe "#save" do
    before do
      stub_const("DBConfig", Class.new do
        def self.get(key)
          nil
        end

        def self.set(key, value)
        end
      end)
    end

    let(:adapter) { described_class.new }

    it "stores the full preferences hash" do
      preferences = {color_scheme: "dark", theme: "slate", accent_color: "blue"}
      allow(DBConfig).to receive(:set)

      adapter.save(user: user, request: request, key: :color_scheme, value: "dark", preferences: preferences)

      expect(DBConfig).to have_received(:set).with("avo_preferences_42", preferences)
    end

    it "uses the custom key prefix for storage" do
      adapter = described_class.new(key_prefix: "custom")
      allow(DBConfig).to receive(:set)

      adapter.save(user: user, request: request, key: :theme, value: "slate", preferences: {theme: "slate"})

      expect(DBConfig).to have_received(:set).with("custom_42", {theme: "slate"})
    end
  end
end
