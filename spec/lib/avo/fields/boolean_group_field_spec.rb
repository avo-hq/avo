require "rails_helper"

RSpec.describe Avo::Fields::BooleanGroupField, type: :model do
  describe "#fill_field" do
    it "replaces the stored copy of an option instead of adding the key a second time" do
      record = Struct.new(:roles).new({"admin" => false, "writer" => true})
      field = described_class.new(:roles, options: {admin: "Administrator", manager: "Manager"})

      field.fill_field(record, :roles, ["admin"], {})

      expect(record.roles).to eq({"writer" => true, :admin => true, :manager => false})
    end
  end
end
