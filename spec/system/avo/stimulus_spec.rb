require "rails_helper"

RSpec.describe "StimulusJS", type: :system do
  let!(:course) { create :course, country: "Japan", city: "Kyoto" }

  describe "edit_controller#toggle" do
    it "toggles off a field" do
      visit "/admin/resources/courses/#{course.id}/edit"

      expect(page).to have_css "[data-field-id='skills']"
      uncheck "course_has_skills"
      expect(page).not_to have_css "[data-field-id='skills']"
      check "course_has_skills"
      expect(page).to have_css "[data-field-id='skills']"
    end
  end

  describe "city-in-country#onCountryChange" do
    it "changes the cities" do
      visit "/admin/resources/courses/#{course.id}/edit"

      expect(page).to have_css "[data-field-id='country']"
      expect(page).to have_css "[data-field-id='city']"
      expect(page).to have_select "course_country"

      select "Spain", from: "course_country"

      expect(page).to have_select "course_country", selected: "Spain"
      expect(page).to have_select "course_city", selected: "Choose an option", options: ["Choose an option", "Madrid", "Valencia", "Barcelona"]

      select "Thailand", from: "course_country"

      expect(page).to have_select "course_country", selected: "Thailand"
      expect(page).to have_select "course_city", selected: "Choose an option", options: ["Choose an option", "Chiang Mai", "Bangkok", "Phuket"]

      select "Japan", from: "course_country"
      expect(page).to have_select "course_country", selected: "Japan"
      expect(page).to have_select "course_city", selected: "Kyoto", options: ["Choose an option", "Tokyo", "Osaka", "Kyoto", "Hiroshima", "Yokohama", "Nagoya", "Kobe"]
    end
  end

  describe "city-in-country#onCountryChange (attached to ShowCurrentTime Action)" do
  it "filters cities based on a given country" do
    visit "/admin/resources/courses"

    click_on "Actions"
    click_on "Show current time"

    expect(page).to have_css "[data-field-id='country']"
    expect(page).to have_css "[data-field-id='city']"
    expect(page).to have_select "fields_country"

    select "Spain", from: "fields_country"

    expect(page).to have_select "fields_country", selected: "Spain"
    expect(page).to have_select "fields_city", selected: "Choose an option", options: ["Choose an option", "Madrid", "Valencia", "Barcelona"]

    select "Thailand", from: "fields_country"

    expect(page).to have_select "fields_country", selected: "Thailand"
    expect(page).to have_select "fields_city", selected: "Choose an option", options: ["Choose an option", "Chiang Mai", "Bangkok", "Phuket"]

    select "Japan", from: "fields_country"
    expect(page).to have_select "fields_country", selected: "Japan"
    select "Kyoto", from: "fields_city"
    expect(page).to have_select "fields_city", selected: "Kyoto", options: ["Choose an option", "Tokyo", "Osaka", "Kyoto", "Hiroshima", "Yokohama", "Nagoya", "Kobe"]

    click_on "Run"

    expect(page).to have_text(/In Kyoto it's now \d\d:\d\d:\d\d./)
  end
end
end
