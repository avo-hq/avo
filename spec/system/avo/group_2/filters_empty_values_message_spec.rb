require "rails_helper"

RSpec.feature "FiltersEmptyValuesMessage", type: :system do
  it "shows the custom empty message" do
    visit "/admin/resources/courses"

    expect(page).not_to have_text "Please select a country to view options."

    open_filters_menu

    expect(page).to have_text "Please select a country to view options."
  end
end
