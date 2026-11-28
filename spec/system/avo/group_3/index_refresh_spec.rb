require "rails_helper"

# avo-hq/avo#3232
RSpec.describe "Index auto-refresh", type: :system do
  around do |example|
    original_project_refresh = Avo::Resources::Project.index_refresh_every
    original_review_refresh = Avo::Resources::Review.index_refresh_every
    Avo::Resources::Project.index_refresh_every = 1.second

    example.run
  ensure
    Avo::Resources::Project.index_refresh_every = original_project_refresh
    Avo::Resources::Review.index_refresh_every = original_review_refresh
  end

  let(:search_input) { find('[data-resource-search-target="input"]') }

  it "shows the records created after the page loaded" do
    create :project, name: "First project"

    visit "/admin/resources/projects"
    expect(page).to have_text("First project")

    create :project, name: "Fresh project"

    expect(page).to have_text("Fresh project")
    expect(page).to have_current_path("/admin/resources/projects")
  end

  it "keeps the search the user typed" do
    create :project, name: "Alpha release"
    create :project, name: "Unrelated project"

    visit "/admin/resources/projects"
    write_in_search("release")
    expect(page).not_to have_text("Unrelated project")

    # The list waits while the user is typing, so leave the search box.
    search_input.send_keys(:escape)
    create :project, name: "Beta release"
    create :project, name: "Another unrelated project"

    expect(page).to have_text("Beta release")
    expect(page).to have_text("Alpha release")
    expect(page).not_to have_text("Unrelated project")
    expect(page).not_to have_text("Another unrelated project")
    expect(search_input.value).to eq("release")
  end

  it "waits while records are selected" do
    create :project, name: "First project"

    visit "/admin/resources/projects"
    row_checkbox(0).click
    create :project, name: "Waiting project"

    # Long enough for two reloads.
    sleep 2.5
    expect(page).not_to have_text("Waiting project")
    expect(row_checkbox(0)).to be_checked

    row_checkbox(0).click

    expect(page).to have_text("Waiting project")
  end

  it "refreshes the records of an association panel" do
    Avo::Resources::Review.index_refresh_every = 1.second
    team = create :team
    create :review, reviewable: team, body: "First review"

    visit "/admin/resources/teams/#{team.to_param}"
    reviews_frame = has_many_field_wrapper(id: :reviews)
    scroll_to reviews_frame
    within(reviews_frame) do
      expect(page).to have_text("First review")
    end

    create :review, reviewable: team, body: "Fresh review"
    create :review, body: "Another team's review"

    within(reviews_frame) do
      expect(page).to have_text("Fresh review")
      expect(page).not_to have_text("Another team's review")
    end
  end
end
