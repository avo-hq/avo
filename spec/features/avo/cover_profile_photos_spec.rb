require "rails_helper"

RSpec.describe "Cover and profile photos", type: :feature do
  let!(:event) {
    create(:event).tap do |event|
      event.profile_photo.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
      event.cover_photo.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
    end
  }

  describe "cover photo" do
    it "displays the cover photo" do
      visit avo.resources_event_path(event)

      # Label on the menu
      expect(page).to have_selector '[data-resource-name="Avo::Resources::Event"] [data-panel-id="main"] [data-component="avo/cover_photo_component"]'
      expect(page).to have_selector '[data-resource-name="Avo::Resources::Event"] [data-panel-id="main"] [data-component="avo/profile_photo_component"]'
    end
  end
end
