require "rails_helper"

RSpec.describe Avo::Fields::BadgeField, type: :model do
  let(:field) { described_class.new(:status) }

  describe "#badge_color_for_value" do
    context "with default identity mappings" do
      %w[success info danger warning neutral].each do |color|
        context "when status is '#{color}'" do
          before do
            allow(field).to receive(:value).and_return(color)
          end

          it { expect(field.badge_color_for_value).to eq(color) }
        end
      end
    end

    context "when normalizing input" do
      it "is case-insensitive" do
        allow(field).to receive(:value).and_return("SUCCESS")
        expect(field.badge_color_for_value).to eq("success")
      end

      it "strips whitespace" do
        allow(field).to receive(:value).and_return("  success  ")
        expect(field.badge_color_for_value).to eq("success")
      end
    end

    context "when status is unknown" do
      before do
        allow(field).to receive(:value).and_return("unknown")
      end

      it { expect(field.badge_color_for_value).to eq("neutral") }
    end

    context "when status is blank" do
      before do
        allow(field).to receive(:value).and_return(nil)
      end

      it { expect(field.badge_color_for_value).to eq("neutral") }
    end
  end

  describe "#normalize" do
    it "converts to lowercase string and strips whitespace" do
      expect(field.send(:normalize, :SUCCESS)).to eq("success")
      expect(field.send(:normalize, "SUCCESS")).to eq("success")
      expect(field.send(:normalize, "  success  ")).to eq("success")
      expect(field.send(:normalize, 123)).to eq("123")
      expect(field.send(:normalize, nil)).to eq("")
    end
  end

  describe "#normalize_list" do
    it "normalizes single values and arrays" do
      expect(field.send(:normalize_list, :success)).to eq(["success"])
      expect(field.send(:normalize_list, "Success")).to eq(["success"])
      expect(field.send(:normalize_list, [:Done, :Complete])).to eq(["done", "complete"])
      expect(field.send(:normalize_list, ["Done", "Complete"])).to eq(["done", "complete"])
      expect(field.send(:normalize_list, [:Done, "Complete", "  Pending  "])).to eq(["done", "complete", "pending"])
    end
  end

  describe "#find_color_for" do
    it "returns color type for matching value" do
      expect(field.send(:find_color_for, "success")).to eq("success")
      expect(field.send(:find_color_for, "info")).to eq("info")
    end

    it "returns nil for unknown value" do
      expect(field.send(:find_color_for, "unknown")).to be_nil
    end
  end
end
