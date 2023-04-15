require "rails_helper"

RSpec.feature "Field Sorting", type: :feature do
  let!(:user) { create :user }
  let!(:project) { create :project }

  describe "sortable field option" do
    it "provides the ability to sort by the ID field by default" do
      visit avo.resources_projects_path

      expect(page).not_to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] div'
      expect(page).to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] a svg'
    end

    it "hides the ability to sort by the id field" do
      visit avo.resources_users_path

      expect(page).to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] div'
      expect(page).not_to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] a svg'
    end
  end
end
