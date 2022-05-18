require "rails_helper"

RSpec.feature "FiltersPanelOpen", type: :system do
  let!(:ny_courses) { create_list :course, 2, city: "New York", country: "USA" }

  describe "when the filters panel should be open" do
    it "keeps the panel open on selection" do
      visit "/admin/resources/courses"

      expect(page).not_to have_text "Course country filter"

      open_filters_menu
      check "USA"
      wait_for_loaded

      expect(page).to have_text "Course country filter"
    end

    it "keeps the panel open on selection and closes them on page changes" do
      visit "/admin/resources/courses?per_page=1"

      expect(page).not_to have_text "Course country filter"

      open_filters_menu
      check "USA"
      wait_for_loaded

      expect(page).to have_text "Course country filter"

      toggle_filters_menu

      # Change the page
      within ".pagy-nav" do
        click_on "2"
      end

      wait_for_loaded

      # Check the filters panel is closed
      expect(page).not_to have_text "Course country filter"
    end
  end

  describe "when the filters panel should be closed" do
    it "keeps the panel closed on selection" do
      visit "/admin/resources/users"

      expect(page).not_to have_text "User names filter"

      open_filters_menu
      fill_in "avo_filters_user_names_filter", with: "Test"
      click_on "Filter by user names"
      wait_for_loaded

      expect(page).not_to have_text "User names filter"
    end
  end
end
