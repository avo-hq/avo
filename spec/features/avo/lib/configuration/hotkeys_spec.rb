require "rails_helper"

RSpec.describe Avo::Configuration, "#hotkeys" do
  let(:config) { described_class.new }

  describe "defaults" do
    it "returns enabled: true, show_key_badges: true when never set" do
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: true})
    end
  end

  describe "partial overrides" do
    it "merges enabled: false with defaults" do
      config.hotkeys = {enabled: false}
      expect(config.hotkeys).to eq({enabled: false, show_key_badges: true})
    end

    it "merges show_key_badges: false with defaults" do
      config.hotkeys = {show_key_badges: false}
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: false})
    end
  end

  describe "empty hash" do
    it "returns full defaults" do
      config.hotkeys = {}
      expect(config.hotkeys).to eq({enabled: true, show_key_badges: true})
    end
  end
end
