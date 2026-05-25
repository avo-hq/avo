require "rails_helper"

RSpec.describe "CheckboxListField", type: :system do
  def checkbox_id(user)
    "team_team_member_ids_#{user.id}"
  end

  def expect_checked_members(*users)
    users.each do |user|
      expect(page).to have_checked_field checkbox_id(user)
    end
  end

  def expect_unchecked_members(*users)
    users.each do |user|
      expect(page).to have_unchecked_field checkbox_id(user)
    end
  end

  it "round-trips checked members through the association setter" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    beta = create :user, first_name: "Beta", last_name: "Two"
    gamma = create :user, first_name: "Gamma", last_name: "Three"
    team = create :team

    visit "/admin/resources/teams/#{team.id}/edit"

    check checkbox_id(alpha)
    check checkbox_id(gamma)

    save

    expect(team.reload.team_member_ids).to match_array [alpha.id, gamma.id]

    visit "/admin/resources/teams/#{team.id}/edit"

    expect_checked_members alpha, gamma
    expect_unchecked_members beta
  end

  it "submits an empty array when every visible option is deselected" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    beta = create :user, first_name: "Beta", last_name: "Two"
    team = create :team, team_members: [alpha, beta]

    visit "/admin/resources/teams/#{team.id}/edit"

    uncheck checkbox_id(alpha)
    uncheck checkbox_id(beta)

    save

    expect(team.reload.team_member_ids).to eq []

    visit "/admin/resources/teams/#{team.id}/edit"

    expect_unchecked_members alpha, beta
  end

  it "rehydrates checked state from submitted params after validation errors" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    beta = create :user, first_name: "Beta", last_name: "Two"
    team = create :team, team_members: [alpha]

    visit "/admin/resources/teams/#{team.id}/edit"

    uncheck checkbox_id(alpha)
    check checkbox_id(beta)
    fill_in "team_name", with: ""
    save

    expect(page).to have_text "Name can't be blank"
    expect_unchecked_members alpha
    expect_checked_members beta
  end

  it "strips stored ids that are no longer present in the current options" do
    visible_member = create :user, first_name: "Visible", last_name: "Member"
    inactive_member = create :user, first_name: "Inactive", last_name: "Member", active: false
    team = create :team, team_members: [visible_member, inactive_member]

    visit "/admin/resources/teams/#{team.id}/edit"

    expect(page).to have_checked_field checkbox_id(visible_member)
    expect(page).not_to have_field checkbox_id(inactive_member)

    save

    expect(team.reload.team_member_ids).to eq [visible_member.id]
  end

  it "renders an empty state when no options are available" do
    team = create :team

    visit "/admin/resources/teams/#{team.id}/edit"

    expect(page).to have_css(".checkbox-list__empty", text: "No options available")
    expect(page).not_to have_css(".checkbox-list__row")
  end

  it "labels the group and toggles rows through native label behavior" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    team = create :team

    visit "/admin/resources/teams/#{team.id}/edit"

    group = find(".checkbox-list")

    expect(group["role"]).to eq "group"
    expect(group["aria-label"]).to eq "Team members"

    find("label.checkbox-list__row", text: alpha.name).click

    expect_checked_members alpha
  end

  it "does not submit checked options hidden by inline search" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    create :user, first_name: "Beta", last_name: "Two"
    team = create :team, team_members: [alpha]

    visit "/admin/resources/teams/#{team.id}/edit"

    fill_in "team_team_member_ids_inline_search", with: "nomatch"

    expect(page).to have_css(".checkbox-list__empty", text: "No matching options", visible: true)
    expect(page).to have_css(".checkbox-list__hidden-selections", text: "1 selected option hidden by search", visible: true)

    save

    expect(team.reload.team_member_ids).to eq []
  end

  it "shows how many checked options are hidden by the current search" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    create :user, first_name: "Beta", last_name: "Two"
    gamma = create :user, first_name: "Gamma", last_name: "Three"
    team = create :team, team_members: [alpha, gamma]

    visit "/admin/resources/teams/#{team.id}/edit"

    fill_in "team_team_member_ids_inline_search", with: "nomatch"

    expect(page).to have_css(".checkbox-list__hidden-selections", text: "2 selected options hidden by search", visible: true)

    search_input = find_field("team_team_member_ids_inline_search")
    page.execute_script(<<~JS, search_input[:id])
      const input = document.getElementById(arguments[0])
      input.value = ""
      input.dispatchEvent(new Event("input", { bubbles: true }))
    JS

    expect(page).to have_css("label.checkbox-list__row", text: alpha.name, visible: true)
    expect(page).to have_css("label.checkbox-list__row", text: gamma.name, visible: true)
    expect(page).not_to have_css(".checkbox-list__hidden-selections", visible: true)
  end

  it "filters options inline and moves through visible rows with arrow keys" do
    alpha = create :user, first_name: "Alpha", last_name: "One"
    beta = create :user, first_name: "Beta", last_name: "Two"
    team = create :team

    visit "/admin/resources/teams/#{team.id}/edit"

    fill_in "team_team_member_ids_inline_search", with: "beta"

    expect(page).to have_css("label.checkbox-list__row", text: beta.name, count: 1)
    expect(page).not_to have_css("label.checkbox-list__row", text: alpha.name, visible: true)

    find_field("team_team_member_ids_inline_search").send_keys(:arrow_down)
    expect(page.evaluate_script("document.activeElement && document.activeElement.id")).to eq checkbox_id(beta)

    find_field(checkbox_id(beta)).send_keys(:space)
    save

    expect(team.reload.team_member_ids).to eq [beta.id]
  end
end
