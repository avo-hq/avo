require "rails_helper"

# Unit 5 — failure handling for manual (`loading: :manual`) frames.
#
# When a manual frame's deferred load fails, the `manual-frame` Stimulus
# controller renders an inline error message + a **Retry** button INSIDE the
# frame. It must NOT navigate to / render the generic `/failed_to_load` page
# (that path is reserved for non-manual frames, whose 500s the global handler
# in `application.js` rewrites). Retry re-issues the request; once the backend
# succeeds the real content loads.
#
# Failures are induced by stubbing `Avo::AssociationsController#index` to raise.
# In Cuprite system tests the dummy app runs in-process, so the stub applies to
# the server-thread request and (with `show_exceptions = :none`) surfaces as a
# real HTTP 500 to the browser.
RSpec.describe "Manual loading failures", type: :system do
  let!(:user) { create :user }
  let!(:comment) { create :comment, user: user, commentable: user }

  # The deliberately-raised controller error must surface to the browser as an
  # HTTP 500 (the behavior we're testing), not be re-raised in the test by
  # Capybara's server-error guard.
  around do |example|
    previous = Capybara.raise_server_errors
    Capybara.raise_server_errors = false
    example.run
    Capybara.raise_server_errors = previous
  end

  describe "a manual frame whose load fails" do
    it "shows the inline error + Retry and does NOT render the failed_to_load page" do
      allow_any_instance_of(Avo::AssociationsController).to receive(:index).and_raise("boom")

      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: :manual
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]')

      within(frame) { click_on "Load Comments" }

      # The inline error + Retry appears inside the frame.
      expect(frame).to have_text("Failed to load Comments")
      expect(frame).to have_button("Retry")

      # We did NOT navigate to (or render into the frame) the generic
      # failed_to_load page. Both UIs say "Failed to load", so distinguish them
      # structurally: the full-page error renders `.state--frame-load-failed`
      # (and has no Retry), the manual inline error does not.
      expect(frame).not_to have_css(".state--frame-load-failed")
      expect(frame[:src]).not_to include("/failed_to_load")
      expect(current_path).to eq(avo.resources_user_path(user))
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "clicking Retry after a failure" do
    it "re-issues the request and loads the real content once the backend succeeds" do
      call_count = 0
      # First load 500s; the retry (second call) is allowed through to the real action.
      allow_any_instance_of(Avo::AssociationsController).to receive(:index).and_wrap_original do |original, *args|
        call_count += 1
        raise "boom" if call_count == 1

        original.call(*args)
      end

      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: :manual
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]')

      within(frame) { click_on "Load Comments" }

      # The first attempt fails -> inline error + Retry.
      expect(frame).to have_button("Retry")

      within(frame) { click_on "Retry" }
      wait_for_loaded

      # The second attempt succeeds -> the real association table renders and the
      # error state is gone.
      expect(page).to have_selector("turbo-frame[id='has_many_field_show_comments'] [data-resource-name='comments'][data-resource-id='#{comment.id}']")
      expect(page).not_to have_button("Retry")
      expect(page).not_to have_text("Failed to load Comments")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  describe "repeated failure" do
    it "keeps the inline error + Retry visible (no broken/empty frame)" do
      allow_any_instance_of(Avo::AssociationsController).to receive(:index).and_raise("boom")

      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many, loading: :manual
      end

      visit avo.resources_user_path(user)

      frame = find('turbo-frame[id="has_many_field_show_comments"]')

      within(frame) { click_on "Load Comments" }
      expect(frame).to have_button("Retry")

      within(frame) { click_on "Retry" }

      # Still failing -> the inline error + Retry stays, the frame is not blank.
      expect(frame).to have_text("Failed to load Comments")
      expect(frame).to have_button("Retry")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end

  # Regression: a NON-manual frame that 500s must still route to the existing
  # `/failed_to_load` page. The manual controller calls `stopImmediatePropagation`
  # only for its own in-flight deferred load, so non-manual frames (and post-load
  # navigations) still reach the global `application.js` handler unchanged.
  describe "a non-manual (eager) frame that 500s (regression)" do
    it "still routes to the existing failed_to_load page" do
      allow_any_instance_of(Avo::AssociationsController).to receive(:index).and_raise("boom")

      Avo::Resources::User.with_temporary_items do
        field :first_name, as: :text
        field :comments, as: :has_many
      end

      visit avo.resources_user_path(user)

      # The eager frame fetches on paint, 500s, and the global handler rewrites
      # its src to /failed_to_load — the existing full-page error UI renders.
      frame = find('turbo-frame[id="has_many_field_show_comments"]')
      expect(frame).to have_css(".state--frame-load-failed", wait: 5)
      # It is the generic page, NOT the manual inline error (which has Retry).
      expect(frame).not_to have_button("Retry")
    ensure
      Avo::Resources::User.restore_items_from_backup
    end
  end
end
