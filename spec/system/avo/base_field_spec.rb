require "rails_helper"

RSpec.feature "Base Fields", type: :system do
  let!(:project) { create :project }

  after :each do
    Avo::Resources::Project.restore_items_from_backup
  end

  describe "base_field_translation_key" do
    it "renders the the default status name" do
      Avo::Resources::Project.with_temporary_items do
        field :status, as: :text
      end

      visit "/admin/resources/projects"

      status_text = find('th[data-control="resource-field-th"][data-table-header-field-id="status"]').text
      expect(status_text).to eq("STATUS")
    end

    it "renders the nested translated key" do
      Avo::Resources::Project.with_temporary_items do
        self.base_field_translation_key = "avo.field_translations.project"
        field :status, as: :text
      end

      visit "/admin/resources/projects"


      status_text = find('th[data-control="resource-field-th"][data-table-header-field-id="status"]').text
      expect(status_text).to eq("STATUS NESTED")
    end
  end
end
