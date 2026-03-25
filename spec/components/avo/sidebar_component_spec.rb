require "rails_helper"

RSpec.describe Avo::SidebarComponent, type: :component do
  describe "#hotkey_for" do
    subject(:component) { described_class.new }

    it "returns the hotkey for items that support it" do
      item = double(hotkey: "p")

      expect(component.hotkey_for(item)).to eq("p")
    end

    it "returns nil for items without a hotkey API" do
      item = Object.new

      expect(component.hotkey_for(item)).to be_nil
    end
  end
end
