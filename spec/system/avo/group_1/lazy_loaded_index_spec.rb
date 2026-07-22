require "rails_helper"

RSpec.describe "Lazy-loaded resource index", type: :system do
  around do |example|
    original_loading = Avo::Resources::Project.index_view_loading
    Avo::Resources::Project.index_view_loading = :lazy

    example.run
  ensure
    Avo::Resources::Project.index_view_loading = original_loading
  end

  it "loads the records and keeps search working" do
    matching_project = create :project, name: "Deferred result"
    other_project = create :project, name: "Unrelated project"

    visit "/admin/resources/projects"

    expect(page).to have_css("turbo-frame#projects_index[complete]")
    expect(page).to have_text(matching_project.name)
    expect(page).to have_text(other_project.name)

    write_in_search("Deferred result")

    expect(page).to have_text(matching_project.name)
    expect(page).not_to have_text(other_project.name)
  end
end
