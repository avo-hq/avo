# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attachment fail", type: :system do
  let!(:user) { create :user }
  let!(:team) { create :team, name: "Haha team" }

  it "if attach persist" do
    ENV["MEMBERSHIP_FAIL"] = "true"

    visit avo.resources_user_path(user, "tab-group_3" => "Teams")

    scroll_to first_tab_group

    click_on "Attach team"

    expect(page).to have_text "Choose team"
    expect(page).to have_select "fields_related_id"

    select team.name, from: "fields_related_id"

    click_on "Attach"
    expect(page).to have_text "Validation failed: Team membership dummy fail."

    ENV["MEMBERSHIP_FAIL"] = "false"
    click_on "Attach"
    expect(page).to have_text "Team attached."
  end
end
