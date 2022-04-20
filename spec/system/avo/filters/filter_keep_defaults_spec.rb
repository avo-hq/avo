require "rails_helper"

RSpec.describe "KeepDefaultsOnfFilterSelection", type: :system do
  describe "when a user updates a filter" do
    it "keeps the defaults for other filters" do
      visit "/admin/resources/users"

      open_filters_menu

      expect(page).to have_select "avo_filters_dummy_multiple_select_filter", selected: ["Yes"], options: ["Yes", "No"]

      fill_in "avo_filters_user_names_filter", with: 'avo'
      find('[data-filter-name="User names filter"] button').click
      wait_for_loaded

      open_filters_menu

      expect(page).to have_select "avo_filters_dummy_multiple_select_filter", selected: ["Yes"], options: ["Yes", "No"]
    end
  end
end

