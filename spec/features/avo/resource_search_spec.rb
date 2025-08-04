# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :system do
  let!(:first_project) { create :project, name: "First Project" }
  let!(:second_project) { create :project, name: "Second Project" }
  let!(:third_project) { create :project, name: "Third Project" }

  it "active record search" do
    visit "/admin/resources/projects"

    expect(page).to have_content(first_project.name)
    expect(page).to have_content(second_project.name)
    expect(page).to have_content(third_project.name)
  end

  it "custom search" do
    visit "/admin/resources/projects?q=#{first_project.name}"

    expect(page).to have_content(first_project.name)
    expect(page).not_to have_content(second_project.name)
    expect(page).not_to have_content(third_project.name)

    write_in_search second_project.name

    expect(page).to have_content(second_project.name)
    expect(page).not_to have_content(first_project.name)
    expect(page).not_to have_content(third_project.name)

    expect(page).to have_current_path("/admin/resources/projects?q=#{second_project.name.gsub(' ', '+')}&page=1")
  end
end
