require "rails_helper"

# Unit 6 coverage for the bulk-update toolbar button. The button lives inside
# the existing ActionsComponent so resources opting in via
# `self.bulk_update = { enabled: true }` get a "Bulk update" link next to the
# Actions picker without a separate component slot. See:
#   docs/plans/2026-05-29-001-feat-bulk-update-plan.md (Unit 6)
#
# Critical wiring assertions (each pinned by a test below):
#   - `data-bulk-update-target="resourceAction"` is DISTINCT from
#     `data-actions-picker-target` so `actions_picker_controller#visitAction`
#     cannot hijack the click into the modal frame.
#   - `data-turbo-frame` is `Avo::SLIDE_OVER_FRAME_ID` (NOT MODAL_FRAME_ID).
#   - `data-disabled` ships true so the link is unclickable until
#     `item_selector_controller#enableBulkUpdateAction` flips it on at N >= 2.
#   - Button hidden entirely when the resource doesn't opt in.
RSpec.describe Avo::ActionsComponent, type: :component do
  let(:project_resource) { Avo::Resources::Project.new(view: Avo::ViewInquirer.new("index")) }
  let(:user_resource) { Avo::Resources::User.new(view: Avo::ViewInquirer.new("index")) }
  let(:dummy_action) { Avo::Actions::ExportCsv.new(record: nil, resource: project_resource, user: nil, view: project_resource.view, arguments: {}) }

  before do
    # `Avo::Resources::Base` delegates `resources_path` to `Avo::Current.view_context`,
    # which in component tests isn't wired with the dummy app's routes. Stub the
    # path-builders so the rendered ActionsComponent (and any embedded actions)
    # can compute their hrefs without hitting `Avo::Current.view_context`.
    allow(project_resource).to receive(:records_path).and_return("/resources/projects")
    allow(project_resource).to receive(:record_path).and_return("/resources/projects/1")
    allow(user_resource).to receive(:records_path).and_return("/admin/resources/users")
    allow(user_resource).to receive(:record_path).and_return("/admin/resources/users/1")
  end

  def render_actions_component(resource:, actions: [], as_row_control: false, &block)
    with_controller_class Avo::BaseController do
      render_inline(described_class.new(
        resource: resource,
        view: resource.view,
        actions: actions,
        as_row_control: as_row_control
      ))
      block&.call
    end
  end

  describe "bulk-update toolbar button" do
    context "when the resource has bulk_update enabled" do
      it "renders the bulk-update link with the bulk-update target attribute" do
        # Project is the dummy resource with `bulk_update: { enabled: true }`.
        # We pass a single action so the dropdown also renders; the bulk-update
        # button must appear alongside it.
        render_actions_component(resource: project_resource, actions: [dummy_action])

        expect(page).to have_css("a[data-bulk-update-target='resourceAction']", text: I18n.t("avo.bulk_update.toolbar.button"))
      end

      it "ships disabled (data-disabled=true) so the click cannot fire until N >= 2 selection lands" do
        render_actions_component(resource: project_resource, actions: [dummy_action])

        link = page.find("a[data-bulk-update-target='resourceAction']")
        expect(link["data-disabled"]).to eq("true")
      end

      it "routes the click into the SLIDE_OVER frame, NOT the MODAL frame" do
        render_actions_component(resource: project_resource, actions: [dummy_action])

        link = page.find("a[data-bulk-update-target='resourceAction']")
        expect(link["data-turbo-frame"]).to eq(Avo::SLIDE_OVER_FRAME_ID.to_s)
        expect(link["data-turbo-frame"]).not_to eq(Avo::MODAL_FRAME_ID.to_s)
      end

      it "does NOT carry the actions-picker target attribute (so visitAction cannot hijack)" do
        render_actions_component(resource: project_resource, actions: [dummy_action])

        link = page.find("a[data-bulk-update-target='resourceAction']")
        expect(link["data-actions-picker-target"]).to be_nil
      end

      it "carries the resource model_key so item_select_all_controller can scope its query" do
        # model_key (not class.to_s) is what `item-selector` / `item-select-all`
        # use everywhere else (the action picker link uses model_key too); this
        # match keeps the toggle logic consistent across both controllers.
        render_actions_component(resource: project_resource, actions: [dummy_action])

        link = page.find("a[data-bulk-update-target='resourceAction']")
        expect(link["data-resource-name"]).to eq(project_resource.model_key)
      end

      it "points at the resource's bulk_update path" do
        render_actions_component(resource: project_resource, actions: [dummy_action])

        link = page.find("a[data-bulk-update-target='resourceAction']")
        expect(link[:href]).to include("/resources/projects/bulk_update")
      end

      it "renders even when there are no Actions to show in the dropdown" do
        # A resource may enable bulk update without defining actions; the button
        # must still appear (otherwise the dropdown-empty case would hide it).
        render_actions_component(resource: project_resource, actions: [])

        expect(page).to have_css("a[data-bulk-update-target='resourceAction']")
      end

      it "is NOT rendered when the ActionsComponent is used as a row control" do
        # Row controls operate on a single record, where N=1 by definition.
        # Bulk update needs N >= 2, so the button has no role inside row controls.
        render_actions_component(resource: project_resource, actions: [dummy_action], as_row_control: true)

        expect(page).not_to have_css("a[data-bulk-update-target='resourceAction']")
      end
    end

    context "when the resource does NOT have bulk_update enabled" do
      it "does not render the bulk-update link at all" do
        # User has no `self.bulk_update = ...` configuration.
        render_actions_component(resource: user_resource, actions: [dummy_action])

        expect(page).not_to have_css("a[data-bulk-update-target='resourceAction']")
      end
    end
  end
end
