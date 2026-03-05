require "rails_helper"

RSpec.describe "Search", type: :system do
  let!(:course) { create :course, name: "Ruby on Rails" }

  describe "resource search with multi-word query" do
    it "finds the record when searching with multiple words" do
      visit "admin/resources/courses"

      click_resource_search_input
      write_in_search("Ruby on Rails")
      select_first_result_in_search

      expect(page).to have_current_path("/admin/resources/courses/#{course.to_param}")
    end

    it "finds the record when searching with a partial multi-word query" do
      visit "admin/resources/courses"

      click_resource_search_input
      write_in_search("Ruby on")
      select_first_result_in_search

      expect(page).to have_current_path("/admin/resources/courses/#{course.to_param}")
    end
  end
end
