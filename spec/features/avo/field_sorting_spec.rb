require "rails_helper"

RSpec.feature "Field Sorting", type: :feature do
  let!(:user) { create :user }
  let!(:project) { create :project }

  describe "sortable field option" do
    it "provides the ability to sort by the ID field by default" do
      visit avo.resources_projects_path

      expect(page).not_to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] div[data-sortable="false"]'
      expect(page).to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] div a svg'
    end

    it "hides the ability to sort by the id field" do
      visit avo.resources_users_path

      expect(page).to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] div[data-sortable="false"]'
      expect(page).not_to have_css 'th[data-control="resource-field-th"][data-table-header-field-id="id"][data-table-header-field-type="id"] a svg'
    end
  end

  describe "sortable link on association tables" do
    # Regression for AVO-1268: on a HABTM/has_many association table rendered
    # inside a parent record's show page, the sort link in the column header
    # pointed at an unrelated resource (whichever resource is first
    # alphabetically) instead of the current parent resource. Reproduced by
    # visiting the users frame under a project and checking that the sort
    # link's href stays under /admin/resources/projects/<id>/users.
    it "preserves the current parent resource path on the sort link" do
      project.users << user

      visit "/admin/resources/projects/#{project.id}/users?turbo_frame=has_and_belongs_to_many_field_show_users&view=show"

      sort_link = find('th[data-control="resource-field-th"][data-table-header-field-id="is_writer"] a')

      expect(sort_link[:href]).to start_with("/admin/resources/projects/#{project.id}/users")
    end
  end
end
