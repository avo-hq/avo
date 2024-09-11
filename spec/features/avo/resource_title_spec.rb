require "rails_helper"

RSpec.feature "Resource title option", type: :feature do
  let!(:project) { create :project }

  it "dont raise any error while visiting show viw with title as id" do
    with_temporary_class_option(Avo::Resources::Project, :title, :id) do
      expect { visit avo.resources_project_path(project) }.not_to raise_error
    end
  end
end
