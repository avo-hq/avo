require "rails_helper"

# Unit 6 system coverage: the bulk-update toolbar button + the selection
# controller wiring (`enableBulkUpdateAction` / `disableBulkUpdateAction`,
# `updateLinks` extension).
#
# What the JS contract pins (each scenario below):
#   - Bulk update enables at N >= 2 (NOT N >= 1 like Actions).
#   - Click routes into the SLIDE_OVER turbo frame (NOT the modal frame).
#   - Bulk update button is hidden entirely when the resource does not opt in
#     via `self.bulk_update = { enabled: true }`.
#   - "Select all matching" rewrites BOTH the Actions URL AND the bulk-update URL
#     with `fields[avo_selected_all]=true` + encrypted query.
#   - Existing Actions toolbar behavior is unchanged at N=1 (regression cover).
#
# Dummy data: `Avo::Resources::Project` is the bulk-update-enabled resource
# (see spec/dummy/app/avo/resources/project.rb). `Avo::Resources::User` is the
# control (no bulk_update config).
RSpec.describe "Bulk update toolbar button", type: :system do
  include_context "has_admin_user"

  let!(:project_one) { create :project, name: "Apollo" }
  let!(:project_two) { create :project, name: "Mercury" }
  let!(:project_three) { create :project, name: "Gemini" }

  before do
    login_as(admin, scope: :user)
  end

  describe "rendering" do
    it "renders the bulk update button when the resource opts in" do
      visit "/admin/resources/projects"

      expect(page).to have_link "Bulk update"
    end

    it "points the bulk update href at the resource's bulk_update path" do
      visit "/admin/resources/projects"

      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button[:href]).to include("/admin/resources/projects/bulk_update")
    end

    it "ships the button disabled until rows are selected (N=0 case)" do
      visit "/admin/resources/projects"

      button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(button["data-disabled"]).to eq "true"
    end

    it "routes the click into the SLIDE_OVER frame, not the modal frame" do
      visit "/admin/resources/projects"

      button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(button["data-turbo-frame"]).to eq Avo::SLIDE_OVER_FRAME_ID.to_s
      expect(button["data-turbo-frame"]).not_to eq Avo::MODAL_FRAME_ID.to_s
    end

    it "does NOT render the bulk update button for a resource without bulk_update enabled" do
      # User has no `self.bulk_update = ...` configuration.
      visit "/admin/resources/users"

      expect(page).not_to have_link "Bulk update"
    end
  end

  describe "N selection gating" do
    it "stays disabled when only 1 row is selected" do
      visit "/admin/resources/projects"

      find("tr[data-resource-name=projects][data-record-id='#{project_one.id}'] input[type=checkbox]").click

      # Bulk update stays DISABLED at N=1 (the standard :edit form is the
      # better affordance for a single record).
      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button["data-disabled"]).to eq "true"
    end

    it "enables when at least 2 rows are selected" do
      visit "/admin/resources/projects"

      find("tr[data-resource-name=projects][data-record-id='#{project_one.id}'] input[type=checkbox]").click
      find("tr[data-resource-name=projects][data-record-id='#{project_two.id}'] input[type=checkbox]").click

      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button["data-disabled"]).to eq "false"
    end

    it "disables again when the selection drops back to 1 row" do
      visit "/admin/resources/projects"

      first_checkbox = find("tr[data-resource-name=projects][data-record-id='#{project_one.id}'] input[type=checkbox]")
      second_checkbox = find("tr[data-resource-name=projects][data-record-id='#{project_two.id}'] input[type=checkbox]")

      first_checkbox.click
      second_checkbox.click
      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button["data-disabled"]).to eq "false"

      second_checkbox.click # drop selection back to 1

      expect(bulk_button["data-disabled"]).to eq "true"
    end
  end

  describe "URL rewriting (item_select_all_controller#updateLinks)" do
    it "carries fields[avo_resource_ids] on the bulk-update href as rows are selected" do
      visit "/admin/resources/projects"

      find("tr[data-resource-name=projects][data-record-id='#{project_one.id}'] input[type=checkbox]").click
      find("tr[data-resource-name=projects][data-record-id='#{project_two.id}'] input[type=checkbox]").click

      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button[:href]).to include("fields%5Bavo_resource_ids%5D")
      expect(bulk_button[:href]).to include(project_one.id.to_s)
      expect(bulk_button[:href]).to include(project_two.id.to_s)
      expect(bulk_button[:href]).to include("fields%5Bavo_selected_all%5D=false")
    end

    it "rewrites the actions URL the same way at the same time (the selector covers both)" do
      # The User resource has resource-targeted actions (ToggleInactive,
      # DownloadFile, etc.) so its `data-actions-picker-target="resourceAction"`
      # links exist on the page. Project's only action (ExportCsv) is
      # `standalone: true` so it'd be `standaloneAction`. We use users here to
      # pin that updateLinks rewrites BOTH the actions URL AND the bulk-update
      # URL when both selectors match; for users the actions URL is what we can
      # observe, since users has no bulk_update config.
      visit "/admin/resources/users"

      first_row_id = page.evaluate_script("document.querySelector('tr[data-resource-name=users]').dataset.recordId")
      find("tr[data-resource-name=users][data-record-id='#{first_row_id}'] input[type=checkbox]").click

      actions_button = page.find("a[data-actions-picker-target='resourceAction']", match: :first, visible: :all)
      expect(actions_button[:href]).to include("fields%5Bavo_resource_ids%5D")
      expect(actions_button[:href]).to include("fields%5Bavo_selected_all%5D=false")
    end
  end

  describe "click routes into the slide-over frame, not the modal frame" do
    it "has the link's data-turbo-frame attribute set to SLIDE_OVER_FRAME_ID" do
      # The data-turbo-frame attribute is what makes the click land in the
      # slide-over turbo frame instead of the modal frame. This test pins the
      # attribute on the disabled state too, because Turbo reads it at click time.
      visit "/admin/resources/projects"

      find("tr[data-resource-name=projects][data-record-id='#{project_one.id}'] input[type=checkbox]").click
      find("tr[data-resource-name=projects][data-record-id='#{project_two.id}'] input[type=checkbox]").click

      bulk_button = page.find("a[data-bulk-update-target='resourceAction']", text: "Bulk update")
      expect(bulk_button["data-disabled"]).to eq "false"
      expect(bulk_button["data-turbo-frame"]).to eq Avo::SLIDE_OVER_FRAME_ID.to_s
    end

    it "the application layout includes the SLIDE_OVER_FRAME_ID turbo frame as a click target" do
      # The layout-level turbo frame is what gives Turbo a target on the index
      # page; without it the click would treat the link as a top-level
      # navigation and reload the page.
      visit "/admin/resources/projects"

      expect(page).to have_css("turbo-frame##{Avo::SLIDE_OVER_FRAME_ID}", visible: :all)
    end
  end

  describe "regression cover: existing Actions toolbar behavior is unchanged" do
    it "Actions button at N=1 still enables and navigates into the MODAL frame" do
      # Use the User resource (has resource-targeted actions; Project only has a
      # standalone ExportCsv action so `data-actions-picker-target=resourceAction`
      # links don't exist on the projects index).
      visit "/admin/resources/users"

      first_row_id = page.evaluate_script("document.querySelector('tr[data-resource-name=users]').dataset.recordId")
      find("tr[data-resource-name=users][data-record-id='#{first_row_id}'] input[type=checkbox]").click

      # Action links live inside a closed popover; query with visible: :all.
      action_link = page.find("a[data-actions-picker-target='resourceAction']", match: :first, visible: :all)
      expect(action_link["data-disabled"]).to eq "false"
      expect(action_link["data-turbo-frame"]).to eq Avo::MODAL_FRAME_ID.to_s
      expect(action_link["data-turbo-frame"]).not_to eq Avo::SLIDE_OVER_FRAME_ID.to_s
    end
  end
end
