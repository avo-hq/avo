require "rails_helper"

RSpec.describe "Avatar and cover photos", type: :feature do
  let!(:event) {
    create(:event).tap do |event|
      event.avatar.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
      event.cover.attach(io: Avo::Engine.root.join("spec", "dummy", "db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
    end
  }

  describe "event page without cover and profile photo" do
    it "does not display the cover and profile photo components" do
      event.avatar.purge
      event.cover.purge
      visit avo.resources_event_path(event)

      expect(page).not_to have_selector '[data-component="avo/cover_component"]'
      expect(page).not_to have_selector '[data-component="avo/avatar_component"]'
    end
  end

  describe "event page with only cover photo" do
    it "displays only the cover photo component" do
      event.avatar.purge
      visit avo.resources_event_path(event)

      expect(page).to have_selector '[data-component="avo/cover_component"]'
      expect(page).not_to have_selector '[data-component="avo/avatar_component"]'
    end
  end

  describe "event page with only profile photo" do
    it "displays only the profile photo component" do
      event.cover.purge
      visit avo.resources_event_path(event)

      expect(page).not_to have_selector '[data-component="avo/cover_component"]'
      expect(page).to have_selector '[data-component="avo/avatar_component"]'
    end
  end

  describe "event page with both cover and profile photos" do
    it "displays both the cover and profile photo components" do
      visit avo.resources_event_path(event)

      expect(page).to have_selector '[data-component="avo/cover_component"]'
      expect(page).to have_selector '[data-component="avo/avatar_component"]'
    end
  end
end
