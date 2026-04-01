require "rails_helper"

RSpec.describe "Search", type: :system do
  let!(:course) { create :course, name: "Ruby on Rails" }
  let!(:other_course) { create :course, name: "Advanced Elixir" }

  describe "resource search with multi-word query" do
    it "finds the record when searching with multiple words" do
      visit "admin/resources/courses"

      write_in_search("Ruby on Rails")

      expect(page).to have_text(/1-1\s+of\s+1/)
      expect(page).to have_selector("[data-component-name='avo/index/table_row_component'][data-resource-id='#{course.to_param}']")
      expect(page).not_to have_selector("[data-component-name='avo/index/table_row_component'][data-resource-id='#{other_course.to_param}']")
    end

    it "finds the record when searching with a partial multi-word query" do
      visit "admin/resources/courses"

      write_in_search("Ruby on")

      expect(page).to have_text(/1-1\s+of\s+1/)
      expect(page).to have_selector("[data-component-name='avo/index/table_row_component'][data-resource-id='#{course.to_param}']")
      expect(page).not_to have_selector("[data-component-name='avo/index/table_row_component'][data-resource-id='#{other_course.to_param}']")
    end
  end
end
