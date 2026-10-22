require "rails_helper"

RSpec.describe Avo::Fields::LocationField do
  # `to_permitted_param` yields the field id and a hash, never the column names, so
  # anything that needs to know which columns back this field has to read them here.
  describe "#stored_as" do
    it "exposes the pair a location is stored across" do
      field = described_class.new(:coordinates, stored_as: [:latitude, :longitude])

      expect(field.stored_as).to eq [:latitude, :longitude]
    end

    it "is nil when the location is stored in one column" do
      field = described_class.new(:coordinates)

      expect(field.stored_as).to be_nil
    end
  end

  describe "#fill_field" do
    it "accepts a single-column location as a [latitude, longitude] pair" do
      record = Struct.new(:coordinates).new
      field = described_class.new(:coordinates)

      field.fill_field(record, :coordinates, ["47.1", "27.6"], {})

      expect(record.coordinates).to eq ["47.1", "27.6"]
    end
  end
end
