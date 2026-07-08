require "rails_helper"

# `loading: {mode: :manual, auto_load_for: <duration>}` — the manual placeholder
# plus a sliding "remember it's open" window.
#
# Once the user opens the frame, the controller writes a short-lived cookie
# (scoped per record + association via the frame's deferred URL). The SERVER
# reads that cookie on the next render and emits a real `<turbo-frame src>` —
# no placeholder, no Load button — so the frame just loads like it did before
# the manual feature. The window slides: each render that finds it remembered
# refreshes the cookie's max-age.
RSpec.describe "Manual loading memory (auto_load_for)", type: :system do
  let!(:user) { create :user }
  let!(:comment) { create :comment, user: user, commentable: user }

  describe "loading: {mode: :manual, auto_load_for: 5.minutes}" do
    it "server-renders a real auto-loading frame (no Load button) on a return visit" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: {mode: :manual, auto_load_for: 5.minutes}
      end

      visit avo.resources_user_path(user)

      # First visit: a plain manual placeholder. Nothing fetched until clicked.
      frame = find('turbo-frame[id="has_many_field_show_comments"]')
      expect(frame[:src]).to be_blank
      expect(frame["data-manual-frame"]).not_to be_nil
      expect(frame).to have_button("Load Comments")

      within(frame) { click_on "Load Comments" }
      wait_for_loaded
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")
      # The `manual-frame` Stimulus controller writes the memory cookie inside
      # its `turbo:frame-load` handler, immediately before setting `tabindex`
      # on the frame. Wait for that attribute so we don't navigate away before
      # the cookie hits disk; otherwise the next render won't see it.
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'][tabindex='-1']", visible: :all)

      # Return to the page (a refresh / following a link back). The cookie tells
      # the server to render a real `<turbo-frame src>` directly — it carries a
      # `src`, is NOT a manual placeholder, and shows no Load button at any point.
      visit avo.resources_user_path(user)
      wait_for_loaded

      reloaded = find('turbo-frame[id="has_many_field_show_comments"]', visible: :all)
      expect(reloaded[:src]).to be_present
      expect(reloaded["data-manual-frame"]).to be_nil
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")
      expect(page).not_to have_button("Load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "loading: :manual (defaults to a 15-minute memory window)" do
    it "server-renders a real auto-loading frame (no Load button) on a return visit" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: :manual
      end

      visit avo.resources_user_path(user)
      within('turbo-frame[id="has_many_field_show_comments"]') { click_on "Load Comments" }
      wait_for_loaded
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")
      # See the matching comment in the 5-minute example above: wait for the
      # `manual-frame` controller to mark the frame so the memory cookie is
      # guaranteed to be written before the next visit.
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'][tabindex='-1']", visible: :all)

      # The default window remembers the opened frame: the next visit auto-loads
      # it directly (a real `<turbo-frame src>`), with no Load button.
      visit avo.resources_user_path(user)
      wait_for_loaded

      reloaded = find('turbo-frame[id="has_many_field_show_comments"]', visible: :all)
      expect(reloaded[:src]).to be_present
      expect(reloaded["data-manual-frame"]).to be_nil
      expect(page).not_to have_button("Load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "loading: {mode: :manual, auto_load_for: 0} (opt out of memory)" do
    it "shows the Load button again on every visit" do
      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: {mode: :manual, auto_load_for: 0}
      end

      visit avo.resources_user_path(user)
      within('turbo-frame[id="has_many_field_show_comments"]') { click_on "Load Comments" }
      wait_for_loaded
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")

      # Opted out -> no memory. The placeholder returns on the next visit.
      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]')
      expect(frame[:src]).to be_blank
      expect(frame).to have_button("Load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end
end
