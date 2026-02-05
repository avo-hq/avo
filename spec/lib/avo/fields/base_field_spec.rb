require "rails_helper"

RSpec.describe Avo::Fields::BaseField do
  describe "#size" do
    it "defaults to :md when not specified" do
      field = described_class.new(:test_field)
      expect(field.size).to eq(:md)
    end

    it "accepts :sm size" do
      field = described_class.new(:test_field, size: :sm)
      expect(field.size).to eq(:sm)
    end

    it "accepts :md size" do
      field = described_class.new(:test_field, size: :md)
      expect(field.size).to eq(:md)
    end

    it "accepts :lg size" do
      field = described_class.new(:test_field, size: :lg)
      expect(field.size).to eq(:lg)
    end

    it "accepts string size values" do
      field = described_class.new(:test_field, size: "sm")
      expect(field.size).to eq("sm")
    end
  end
end
