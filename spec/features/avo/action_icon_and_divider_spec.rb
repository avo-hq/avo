require "rails_helper"

RSpec.describe "action icon and divider", type: :feature do
  describe "icon and divider" do
    it "Viewing actions with icon and divider" do
      visit "admin/resources/users"

      expect(page).to have_css("button[data-action='click->toggle#togglePanel']")

      # Stroke caps live on the root <svg>, not on each <path> — match by path data only.
      expect(page).to have_css("path[d*='M3.6 9']", visible: false) # Tabler world (ToggleInactive action)
      expect(page).to have_css("path[d*='M5 12l6 6']", visible: false) # Tabler arrow-left (DownloadFile action)
      expect(page).to have_css("[data-component-name='avo/divider_component']", visible: false)
    end
  end
end
