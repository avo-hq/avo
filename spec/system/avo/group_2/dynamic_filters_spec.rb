require "rails_helper"

RSpec.describe "DynamicFilters", type: :system do
  it "populates the cities list" do
    visit "/admin/resources/courses"

    expect(page).not_to have_text "Course country filter"

    open_filters_menu
    check "USA"
    wait_for_loaded

    expect(page).to have_text "Course country filter"
    expect(page).to have_field "avo_filters_course_city_filter", checked: true, with: "New York"
    Course.cities.stringify_keys["USA"].drop(1).each do |city|
      expect(page).to have_field "avo_filters_course_city_filter", checked: false, with: city
    end
    Course.cities.stringify_keys["Japan"].each do |city|
      expect(page).not_to have_field "avo_filters_course_city_filter", with: city
    end

    check "Japan"
    wait_for_loaded

    Course.cities.stringify_keys["USA"].drop(1).each do |city|
      expect(page).to have_field "avo_filters_course_city_filter", checked: false, with: city
    end
    Course.cities.stringify_keys["Japan"].each do |city|
      expect(page).to have_field "avo_filters_course_city_filter", checked: false, with: city
    end
  end
end
