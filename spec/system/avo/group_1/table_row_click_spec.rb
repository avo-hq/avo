# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Table row click navigation", type: :system do
  let!(:project) { create(:project, name: "Clickable project") }

  it "delegates click handling from tbody to the row visit path" do
    visit "/admin/resources/projects"

    tbody = find("tbody[data-controller~='table-row']")
    row = find("tr[data-visit-path='#{avo.resources_project_path(project)}']")
    expect(row[:"data-action"]).to be_nil

    tbody.find("td", text: "Clickable project").click

    expect(page).to have_current_path(avo.resources_project_path(project))
  end

  it "does not navigate when clicking the row selector checkbox" do
    visit "/admin/resources/projects"

    find(".item-selector-cell input[type='checkbox']", match: :first).click

    expect(page).to have_current_path("/admin/resources/projects")
  end
end
