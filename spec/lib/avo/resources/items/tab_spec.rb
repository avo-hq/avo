require "rails_helper"

RSpec.describe Avo::Resources::Items::Tab, type: :model do
  describe "#manual?" do
    it "is true with loading: :manual" do
      tab = described_class.new(title: "Orders", loading: :manual)

      expect(tab.manual?).to be true
    end

    it "tolerates the string \"manual\"" do
      tab = described_class.new(title: "Orders", loading: "manual")

      expect(tab.manual?).to be true
    end

    it "defaults to false when loading: is omitted" do
      tab = described_class.new(title: "Orders")

      expect(tab.manual?).to be false
    end

    it "is false for a lazy_load tab and keeps lazy_load working" do
      tab = described_class.new(title: "Orders", lazy_load: true)

      expect(tab.lazy_load).to be true
      expect(tab.manual?).to be false
    end

    it "is true when both loading: :manual and lazy_load: true are set" do
      tab = described_class.new(title: "Orders", loading: :manual, lazy_load: true)

      expect(tab.lazy_load).to be true
      expect(tab.manual?).to be true
    end
  end
end
