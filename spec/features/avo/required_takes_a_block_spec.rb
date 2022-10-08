require "rails_helper"

RSpec.feature "RequiredTakesABlock", type: :feature do
  context "new" do
    it "is required" do
      visit "/admin/resources/fish/new"

      within '[data-resource-edit-target="nameTextWrapper"][data-field-id="name"]' do
        expect(page).to have_selector ".text-red-600.ml-1"
      end
    end
  end

  context "edit" do
    let(:fish) { create :fish }

    it "is required" do
      visit "/admin/resources/fish/#{fish.id}/edit"

      within '[data-resource-edit-target="nameTextWrapper"][data-field-id="name"]' do
        expect(page).not_to have_selector ".text-red-600.ml-1"
      end
    end
  end
end
