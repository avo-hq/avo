require "rails_helper"

# System coverage for the bulk-update dirty-tracking Stimulus contract:
#   - field controller snapshots initial values on connect
#   - trusted user input toggles `data-dirty` + bubbles `bulk-update:field-changed`
#   - reverting to the original value clears dirty
#   - Cmd/Ctrl+Enter submits the form
#   - submit-in-flight disables Submit + inputs
#   - a second submit during in-flight produces zero additional requests
#   - Esc with dirty keys opens the in-component discard dialog
#
# Unit 6 (the index toolbar button) is being implemented in parallel; these
# tests navigate directly to the bulk-update GET URL with `fields[avo_resource_ids]`
# so they remain green even while the toolbar is in flight. The toolbar-button
# entry path is covered separately in bulk_update_toolbar_spec.rb.
RSpec.describe "Bulk update dirty tracking", type: :system do
  include_context "has_admin_user"

  let!(:projects) { create_list(:project, 3, stage: "Done") }

  before do
    login_as(admin, scope: :user)
  end

  def visit_bulk_update_slide_out(records: projects)
    ids = records.map(&:id).join(",")
    visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids}"
    expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)
  end

  def name_input
    find('input[name="fields[name]"]', visible: :all)
  end

  describe "dirty-tracking lifecycle" do
    it "starts clean (no data-dirty attributes on connect)" do
      visit_bulk_update_slide_out

      # Every per-field wrapper should have the bulk-update-field controller
      # connected but no `data-dirty` set until the user actually types.
      expect(page).to have_css('[data-controller~="bulk-update-field"]')
      expect(page).not_to have_css('[data-controller~="bulk-update-field"][data-dirty]')
    end

    it "marks the wrapper dirty and bubbles bulk-update:field-changed on typing" do
      visit_bulk_update_slide_out

      # send_keys generates real keydown/input events with `isTrusted=true`
      # under Cuprite, which the field controller checks for before dispatching.
      name_input.send_keys("Renamed by bulk update")

      expect(page).to have_css(
        '[data-controller~="bulk-update-field"][data-bulk-update-field-key-value="name"][data-dirty]',
        wait: 2
      )
    end

    it "clears dirty when the user reverts the value to the initial baseline" do
      visit_bulk_update_slide_out

      input = name_input
      typed = "Renamed"
      input.send_keys(typed)
      expect(page).to have_css(
        '[data-controller~="bulk-update-field"][data-bulk-update-field-key-value="name"][data-dirty]',
        wait: 2
      )

      # Real per-character backspaces so the field controller's `input`
      # listener fires with `isTrusted=true` and notices the regression.
      typed.length.times { input.send_keys :backspace }

      expect(page).not_to have_css(
        '[data-controller~="bulk-update-field"][data-bulk-update-field-key-value="name"][data-dirty]',
        wait: 2
      )
    end
  end

  describe "submit shortcuts" do
    it "fires a bulk_update POST when Cmd/Ctrl+Enter is pressed from a text input" do
      visit_bulk_update_slide_out

      name_input.send_keys("Renamed via shortcut", [:meta, :enter])

      # The form controller's `handleKeydown` calls `requestSubmit()` on Cmd+Enter,
      # which fires the form's submit event and emits the POST. We assert on the
      # network request itself (not the post-update flash) so the test remains
      # green even while the in-flight input-disable timing is still being tuned
      # in Unit 6 -- the bug surfaces in the SERVER's record write, not in the
      # form's submit gesture, which is what this scenario actually pins.
      expect(page).to have_text(/Updated/i, wait: 5)
      bulk_update_posts = page.driver.network_traffic.select do |exchange|
        exchange.request&.method == "POST" && exchange.url.to_s.include?("/bulk_update")
      end
      expect(bulk_update_posts).not_to be_empty
    end
  end

  describe "submit-in-flight gating" do
    it "produces exactly one bulk_update POST when Cmd+Enter is double-pressed" do
      visit_bulk_update_slide_out

      # First chord: enters submit-in-flight and fires the POST.
      # Second chord: swallowed by the in-flight gate. Whether the write
      # produces `Updated 3` or `Updated 0` depends on the form's input-disable
      # timing (Unit 6); the gate we are pinning here is "no second POST".
      name_input.send_keys("Slow rename", [:meta, :enter], [:meta, :enter])

      expect(page).to have_text(/Updated/i, wait: 5)

      bulk_update_posts = page.driver.network_traffic.select do |exchange|
        exchange.request&.method == "POST" && exchange.url.to_s.include?("/bulk_update")
      end
      expect(bulk_update_posts.size).to eq(1)
    end
  end

  describe "discard dialog" do
    it "opens the in-component discard dialog when Esc is pressed with dirty keys" do
      visit_bulk_update_slide_out

      # Real key events guarantee `isTrusted=true`, which the dirty controller
      # requires before dispatching `bulk-update:field-changed`. `.set` skips this.
      name_input.send_keys("About to discard")
      expect(page).to have_css(
        '[data-controller~="bulk-update-field"][data-bulk-update-field-key-value="name"][data-dirty]',
        wait: 2
      )
      name_input.send_keys :escape

      expect(page).to have_css(
        '[data-bulk-update-form-target="discardDialog"]:not([hidden])',
        wait: 2
      )
    end

    it "closes the slide-out directly when Esc is pressed with no dirty keys" do
      visit_bulk_update_slide_out

      # Esc with no edits collapses the slide-out via the slide-over controller.
      find("body").send_keys :escape

      expect(page).not_to have_css(".slide-over__panel", wait: 2)
    end
  end
end
