require "rails_helper"

RSpec.feature "CustomResourceControls", type: :system do
  let!(:fish) { create :fish }

  describe ".show" do
    it "runs the turbo link" do
      visit "/admin/resources/fish/#{fish.id}"

      click_on "Turbo demo"
      wait_for_loaded

      expect(page).to have_text "🚀🚀🚀 I told you it will change 🚀🚀🚀"
    end

    it "shows the action" do
      visit "/admin/resources/fish/#{fish.id}"

      click_on "Release fish"
      wait_for_loaded

      expect(page).to have_text "Are you sure you want to release this fish?"
    end
  end
end
