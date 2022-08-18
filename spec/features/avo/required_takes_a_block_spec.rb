require 'rails_helper'

RSpec.feature "RequiredTakesABlocks", type: :feature do
  context "new" do
    it "is required" do
      visit "/admin/resources/fish/new"

      expect(page).to have_selector ".text-red-600.ml-1"
      expect(page).to have_required_field "fish[name]"
    end
  end

  context "edit" do
    let(:fish) { create :fish }

    it "is required" do
      visit "/admin/resources/fish/#{fish.id}/edit"

      expect(page).not_to have_selector ".text-red-600.ml-1"
      expect(page).not_to have_required_field("fish[name]")
    end
  end
end
