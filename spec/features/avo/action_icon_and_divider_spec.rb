require "rails_helper"

RSpec.describe "action icon and divider", type: :feature do
  describe "icon and divider" do
    it "Viewing actions with icon and divider" do
      visit "admin/resources/users"

      expect(page).to have_css("button[data-action='click->toggle#togglePanel']")

      expect(page).to have_css("path[stroke-linecap='round'][stroke-linejoin='round'][d*='M3.055 11']", visible: false) # the earth icon
      expect(page).to have_css("path[stroke-linecap='round'][stroke-linejoin='round'][d*='M10.5 19.5']", visible: false) # the arrow icon
      expect(page).to have_css("[data-component-name='avo/divider_component']", visible: false)
    end
  end
end
