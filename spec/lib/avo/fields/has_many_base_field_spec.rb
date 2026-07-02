require "rails_helper"

RSpec.describe Avo::Fields::HasManyField, type: :model do
  describe "#attach_using_checkbox_list?" do
    it "is enabled with attach_using: :checkbox_list" do
      field = described_class.new(:users, attach_using: :checkbox_list)

      expect(field.attach_using_checkbox_list?).to be true
    end

    it "accepts atach_using as a typo-tolerant alias" do
      field = described_class.new(:users, atach_using: :checkbox_list)

      expect(field.attach_using_checkbox_list?).to be true
    end

    it "defaults to false" do
      field = described_class.new(:users)

      expect(field.attach_using_checkbox_list?).to be false
    end
  end
end
