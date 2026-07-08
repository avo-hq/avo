require "rails_helper"

RSpec.describe "ProgressBarField", type: :system do
  describe "able to contain nil value" do
    context "create" do
      it "progress field remains blank" do
        visit "/admin/resources/projects/new"

        fill_in "project[users_required]", with: 10

        click_button "Save"
        sleep 2

        expect(Project.last.progress).to eq(nil)
      end
    end
  end
end
