# frozen_string_literal: true

require "rails_helper"

# Regression spec for the "page scroll locked after successful attach" bug.
#
# Repro: opening an attach modal adds `modal-open` to <body> (CSS rule
# `body.modal-open { overflow: hidden }` locks background scroll while
# the modal is open). A successful attach closes the modal via a
# turbo_stream that replaces the modal frame — the modal element is
# detached from the DOM, Stimulus fires `disconnect()`, but `disconnect()`
# never strips `modal-open` from <body>. Result: page stays scroll-locked
# after the modal disappears.
#
# This spec fails on the buggy code and passes once `disconnect()` in
# `modal_controller.js` also calls `removeModalOpen()`.
RSpec.describe "Modal scroll lock is released after a successful attach", type: :system do
  let!(:user) { create :user }
  let!(:team) { create :team, name: "Haha team" }

  it "removes the modal-open class from <body> after attach succeeds" do
    visit avo.resources_user_path(user, "tab-group_first-tabs-group" => "Teams")

    scroll_to first_tab_group

    click_on "Attach team"

    expect(page).to have_select "fields_related_id"
    select team.name, from: "fields_related_id"

    click_on "Attach"

    expect(page).to have_text "Team attached."
    expect(page).not_to have_selector('[aria-modal="true"]')

    expect(page).not_to have_css("body.modal-open")
  end
end
