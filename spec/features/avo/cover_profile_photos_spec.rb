require "rails_helper"

RSpec.describe "Cover and profile photos", type: :feature do
  let!(:event) {
    create(:event).tap do |event|
      event.profile_photo.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
      event.cover_photo.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
    end
  }

  describe "event page without cover and profile photo" do
    it "does not display the cover and profile photo components" do
      event.profile_photo.purge
      event.cover_photo.purge
      visit avo.resources_event_path(event)

      expect(page).not_to have_selector '[data-component="avo/cover_photo_component"]'
      expect(page).not_to have_selector '[data-component="avo/profile_photo_component"]'
    end
  end

  describe "event page with only cover photo" do
    it "displays only the cover photo component" do
      event.profile_photo.purge
      visit avo.resources_event_path(event)

      expect(page).to have_selector '[data-component="avo/cover_photo_component"]'
      expect(page).not_to have_selector '[data-component="avo/profile_photo_component"]'
    end
  end

  describe "event page with only profile photo" do
    it "displays only the profile photo component" do
      event.cover_photo.purge
      visit avo.resources_event_path(event)

      expect(page).not_to have_selector '[data-component="avo/cover_photo_component"]'
      expect(page).to have_selector '[data-component="avo/profile_photo_component"]'
    end
  end

  describe "event page with both cover and profile photos" do
    it "displays both the cover and profile photo components" do
      visit avo.resources_event_path(event)

      expect(page).to have_selector '[data-component="avo/cover_photo_component"]'
      expect(page).to have_selector '[data-component="avo/profile_photo_component"]'
    end
  end
end
