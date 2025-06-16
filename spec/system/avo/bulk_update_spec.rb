require "rails_helper"

RSpec.describe "Actions", type: :system do
  let!(:user) { create :user }
  let!(:project) { create :project }
  let!(:second_project) { create :project }

  describe "check visibility" do
    context "index" do
      before do
        visit "/admin/resources/projects"
      end
      it "does not finds a button on index" do
        expect(page).not_to have_link("Bulk update")
      end
      it "button appears after check projects" do
        check_and_select_projects
        expect(page).to have_link("Bulk update")
      end
    end
  end

  describe "check redirect functionality" do
    context "with selected records" do
      it "redirects to edit form page" do
        visit "/admin/resources/projects"

        check_and_select_projects

        find("a", text: "Bulk update").click

        expect(page).to have_current_path("/admin/bulk_update/edit", ignore_query: true)
        expect(page).to have_button("Save")
      end
    end
  end

  describe "check bulk update" do
    before do
      visit "/admin/resources/projects"
      check_and_select_projects
      find("a", text: "Bulk update").click
    end

    context "with no changes in form" do
      it "works correctly" do
        visit "/admin/resources/projects"
        check_and_select_projects
        find("a", text: "Bulk update").click

        find("button", text: "Save").click

        expect(page).to have_text "Bulk action run successfully."
      end
    end

    context "with valid params" do
      it "works correctly" do
        fill_in "project_name", with: "Test"
        select "Virgin Islands, U.S.", from: "project_country"
        find("button", text: "Save").click

        project.reload
        second_project.reload

        expect(page).to have_current_path("/admin/resources/projects")
        expect(page).to have_text "Bulk action run successfully."
        expect(project.name).to eq "Test"
        expect(second_project.country).to eq "VI"
      end
    end
  end

  private

  def check_and_select_projects
    checkboxes = all('input[type="checkbox"][name="Select item"]')
    checkboxes[0].click
    checkboxes[1].click

    expect(checkboxes[0].checked?).to be true
    expect(checkboxes[1].checked?).to be true
  end
end
