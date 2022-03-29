require "rails_helper"

RSpec.feature "ShowPages", type: :feature do
  describe "fish without name" do
    let(:fish) { create :fish, name: "" }

    it "shows the record panel" do
      visit "/admin/resources/fish/#{fish.id}"

      expect(find_field_value_element("name")).to have_text empty_dash
    end
  end

  describe "fish with name" do
    let(:fish) { create :fish, name: "Coco" }

    it "shows the record panel" do
      visit "/admin/resources/fish/#{fish.id}"

      expect(find_field_value_element("name")).to have_text "Coco"
    end
  end
end
