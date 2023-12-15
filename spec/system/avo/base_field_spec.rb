require "rails_helper"

RSpec.feature "Base Fields", type: :system do
  let(:project) { create :project, :with_files }

  after :each do
    Avo::Resources::Project.restore_items_from_backup
  end

  describe "base_field_translation_key" do
    it "renders the the default status name" do
      Avo::Resources::Project.with_temporary_items do
        self.base_field_translation_key = nil

        field :status, as: :text
      end

      visit "/admin/resources/projects"

      status_wrapper = find('[data-table-header-field-type="status"]')
      expect(status_wrapper).to have_text("Status")
    end

    it "renders the nested translated key" do
      Avo::Resources::Project.with_temporary_items do
        field :status, as: :text
      end

      visit "/admin/resources/projects"

      status_wrapper = find('[data-table-header-field-type="status"]')
      expect(status_wrapper).to have_text("Status nested")
    end
  end
end
