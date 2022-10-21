require "rails_helper"

RSpec.feature "ResourceSidebars", type: :feature do
  let(:fish) { create :fish }
  let(:team) { create :team }

  it "does not display the sidebar on a resource that does not have a sidebar" do
    visit avo.resources_fish_path(fish)

    expect(page).not_to have_css ".resource-sidebar-component"
  end

  it "displays the sidebar on a resource that has a sidebar" do
    visit avo.resources_user_path(admin)

    expect(page).to have_css ".resource-sidebar-component"
  end

  it "displays the sidebar on a resource that has a sidebar 2" do
    visit avo.resources_team_path(team)

    expect(page).to have_css ".resource-sidebar-component"
  end
end
