require "rails_helper"

RSpec.feature "Field Sorting", type: :system do
  let!(:project) { create :project }

  describe "sortable field option" do
    it "shows the next action as a title" do
      visit avo.resources_projects_path

      expect(page).not_to have_current_path(/sort_direction=/)

      first('svg[data-tippy-content="Sort descending"]').click
      expect(page).to have_current_path(/sort_direction=desc/)

      first('svg[data-tippy-content="Sort ascending"]').click
      expect(page).to have_current_path(/sort_direction=asc/)

      first('svg[data-tippy-content="Reset sorting"]').click
      expect(page).not_to have_current_path(/sort_direction=/)
    end
  end
end
