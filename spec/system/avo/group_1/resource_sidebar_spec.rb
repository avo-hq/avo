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

  it "wraps long unbroken values inside the sidebar" do
    team.update!(url: "https://example.com/#{"a" * 200}")
    visit avo.resources_team_path(team)

    # Measure the text itself: the card clips it, so the value's box never grows.
    overflow = page.evaluate_script(<<~JS)
      (() => {
        const sidebar = document.querySelector('.panel__sidebar')
        const text = document.createRange()
        text.selectNodeContents(document.querySelector('.resource-sidebar-component [data-field-id="url"] .field-wrapper__content-wrapper'))
        return text.getBoundingClientRect().right - sidebar.getBoundingClientRect().right
      })()
    JS

    expect(overflow).to be <= 0
  end

  it "allow fields to be edited on sidebar" do
    admin.update!(custom_css: "")
    visit avo.edit_resources_user_path(admin)

    within ".CodeMirror" do
      current_scope.click
      type "Some custom css"
    end

    save

    expect(page).to have_css(".CodeMirror-code", text: "Some custom css")
  end
end
