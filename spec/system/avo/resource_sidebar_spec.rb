require "rails_helper"

RSpec.feature "ResourceSidebars", type: :system do
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

  it "allow fields to be eddited on sidebar" do
    admin.update!(custom_css: "")
    visit avo.edit_resources_user_path(admin)

    within ".CodeMirror" do
      current_scope.click
      field = current_scope.find("textarea", visible: false)
      field.send_keys "Some custom css"
    end

    click_on "Save"
    wait_for_loaded

    expect(page).to have_css(".CodeMirror-code", text: "Some custom css")
  end
end
