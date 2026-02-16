require "rails_helper"

RSpec.describe Avo::Configuration do
  subject(:configuration) { described_class.new }

  describe "#user_preferences" do
    it "defaults to nil" do
      expect(configuration.user_preferences).to be_nil
    end

    it "accepts a hash with load and save lambdas" do
      prefs = {
        load: ->(user:, request:) { {} },
        save: ->(user:, request:, key:, value:, preferences:) { }
      }
      configuration.user_preferences = prefs
      expect(configuration.user_preferences).to eq(prefs)
    end

    it "accepts an adapter object responding to load and save" do
      adapter = double("adapter", load: {}, save: nil)
      configuration.user_preferences = adapter
      expect(configuration.user_preferences).to eq(adapter)
    end
  end

  describe "#user_preferences_configured?" do
    it "returns false when user_preferences is nil" do
      configuration.user_preferences = nil
      expect(configuration.user_preferences_configured?).to be false
    end

    it "returns true when user_preferences is a hash" do
      configuration.user_preferences = {
        load: ->(user:, request:) { {} },
        save: ->(user:, request:, key:, value:, preferences:) { }
      }
      expect(configuration.user_preferences_configured?).to be true
    end

    it "returns true when user_preferences is an adapter object" do
      adapter = double("adapter", load: {}, save: nil)
      configuration.user_preferences = adapter
      expect(configuration.user_preferences_configured?).to be true
    end
  end

  describe "#user_preference_keys" do
    it "defaults to an empty array" do
      expect(configuration.user_preference_keys).to eq([])
    end

    it "accepts an array of custom key names" do
      configuration.user_preference_keys = [:sidebar_collapsed, :items_per_page]
      expect(configuration.user_preference_keys).to eq([:sidebar_collapsed, :items_per_page])
    end
  end

  describe "#all_user_preference_keys" do
    it "includes built-in keys" do
      expect(configuration.all_user_preference_keys).to include(:color_scheme, :theme, :accent_color)
    end

    it "includes custom keys" do
      configuration.user_preference_keys = [:sidebar_collapsed]
      expect(configuration.all_user_preference_keys).to include(:sidebar_collapsed)
    end

    it "merges built-in and custom keys" do
      configuration.user_preference_keys = [:sidebar_collapsed, :items_per_page]
      expect(configuration.all_user_preference_keys).to eq([:color_scheme, :theme, :accent_color, :sidebar_collapsed, :items_per_page])
    end
  end

  describe "#load_user_preferences" do
    let(:user) { double("user", id: 1) }
    let(:request) { double("request") }

    context "with hash of lambdas" do
      it "calls the load lambda with user and request" do
        loaded_prefs = {color_scheme: "dark", theme: "slate"}
        configuration.user_preferences = {
          load: ->(user:, request:) { loaded_prefs },
          save: ->(user:, request:, key:, value:, preferences:) { }
        }

        result = configuration.load_user_preferences(user: user, request: request)
        expect(result).to eq(loaded_prefs)
      end
    end

    context "with adapter object" do
      it "calls the adapter's load method" do
        loaded_prefs = {color_scheme: "light"}
        adapter = double("adapter")
        allow(adapter).to receive(:load).with(user: user, request: request).and_return(loaded_prefs)
        allow(adapter).to receive(:save)

        configuration.user_preferences = adapter
        result = configuration.load_user_preferences(user: user, request: request)
        expect(result).to eq(loaded_prefs)
      end
    end
  end

  describe "#save_user_preferences" do
    let(:user) { double("user", id: 1) }
    let(:request) { double("request") }

    context "with hash of lambdas" do
      it "calls the save lambda with all arguments" do
        saved_args = nil
        configuration.user_preferences = {
          load: ->(user:, request:) { {} },
          save: ->(user:, request:, key:, value:, preferences:) { saved_args = {key: key, value: value, preferences: preferences} }
        }

        preferences = {color_scheme: "dark", theme: "slate"}
        configuration.save_user_preferences(user: user, request: request, key: :color_scheme, value: "dark", preferences: preferences)

        expect(saved_args).to eq({key: :color_scheme, value: "dark", preferences: preferences})
      end
    end

    context "with adapter object" do
      it "calls the adapter's save method" do
        adapter = double("adapter")
        allow(adapter).to receive(:load)
        expect(adapter).to receive(:save).with(
          user: user,
          request: request,
          key: :theme,
          value: "slate",
          preferences: {theme: "slate"}
        )

        configuration.user_preferences = adapter
        configuration.save_user_preferences(user: user, request: request, key: :theme, value: "slate", preferences: {theme: "slate"})
      end
    end
  end
end
