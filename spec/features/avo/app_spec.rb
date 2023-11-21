require "rails_helper"

RSpec.describe "App", type: :feature do
  describe "custom tool works" do
    it "redirects to the admin page" do
      visit "/admin/custom_tool"

      expect(current_path).to eq "/admin/custom_tool"

      # Label on the menu
      expect(page).to have_text "Fish"
    end
  end

  describe "Current.user is set" do
    it "displayes the current user" do
      visit "/admin/custom_tool"

      # Label on the menu builder
      expect(page).to have_text "Current.user.id = #{admin.id}"
    end
  end

  describe "callable app_name" do
    it "displayes the app name with a param" do
      visit "/admin/custom_tool?app_name_suffix=yup"

      # Label on the menu builder
      expect(page).to have_text "Avocadelicious yup"
    end
  end
end
