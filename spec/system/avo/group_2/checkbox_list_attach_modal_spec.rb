# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Checkbox list attach modal", type: :system do
  it "attaches multiple has_many through records" do
    team = create :team
    alpha = create :user, first_name: "Alpha", last_name: "One"
    beta = create :user, first_name: "Beta", last_name: "Two"

    visit "/admin/resources/teams/#{team.id}/team_members/new?view=show"

    expect(page).to have_css(".checkbox-list__row", text: alpha.name)
    expect(page).to have_css(".checkbox-list__row", text: beta.name)
    expect(page).not_to have_select "fields_related_id"

    check "fields_related_id_#{alpha.id}"
    check "fields_related_id_#{beta.id}"

    expect {
      click_button "Attach"
      wait_for_loaded
    }.to change { team.reload.team_members.count }.by 2

    expect(team.team_members).to include alpha, beta
  end

  it "attaches multiple has_and_belongs_to_many records" do
    user = create :user
    alpha = create :project, name: "Alpha"
    beta = create :project, name: "Beta"

    visit "/admin/resources/users/#{user.id}/projects/new?view=show"

    expect(page).to have_css(".checkbox-list__row", text: alpha.name)
    expect(page).to have_css(".checkbox-list__row", text: beta.name)
    expect(page).not_to have_select "fields_related_id"

    check "fields_related_id_#{alpha.id}"
    check "fields_related_id_#{beta.id}"

    expect {
      click_button "Attach"
      wait_for_loaded
    }.to change { user.reload.projects.count }.by 2

    expect(user.projects).to include alpha, beta
  end
end
