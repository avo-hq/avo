require "rails_helper"

RSpec.feature "direct_upload", type: :system do
  describe "multiple files" do
    it "uploads multiple files" do
      visit avo.new_resources_project_path

      fill_in "project_users_required", with: 51

      attach_file("project_files", [
        Rails.root.join("db", "seed_files", "dummy-file.txt"),
        Rails.root.join("db", "seed_files", "dummy-file.pdf")
      ], make_visible: true)

      click_on "Save"

      expect(page).to have_text("Project was successfully created.")
    end
  end
end
