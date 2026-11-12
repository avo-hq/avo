require "rails_helper"

# avo-hq/avo#3232
RSpec.describe "Index auto-refresh", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:search_headers) { {"Accept" => "text/vnd.turbo-stream.html", "X-Search-Request" => "resource-search-controller"} }

  before do
    login_as admin_user
  end

  around do |example|
    original_project_refresh = Avo::Resources::Project.index_refresh_every
    original_review_refresh = Avo::Resources::Review.index_refresh_every

    example.run
  ensure
    Avo::Resources::Project.index_refresh_every = original_project_refresh
    Avo::Resources::Review.index_refresh_every = original_review_refresh
  end

  def listing(id = "projects_body_content")
    Nokogiri::HTML(response.body).at_css("##{id}")
  end

  it "doesn't refresh the records by default" do
    create :project

    get "/admin/resources/projects"

    expect(listing).to be_present
    expect(response.body).not_to include("resource-refresh")
  end

  it "refreshes the records from the page's URL" do
    Avo::Resources::Project.index_refresh_every = 30.seconds
    create :project

    get "/admin/resources/projects?sort_by=name&sort_direction=asc&page=1"

    expect(listing["data-controller"]).to eq("resource-refresh")
    expect(listing["data-resource-refresh-interval-value"]).to eq("30000")
    expect(listing["data-resource-refresh-url-value"]).to eq("/admin/resources/projects?sort_by=name&sort_direction=asc&page=1")
  end

  it "takes the interval in seconds" do
    Avo::Resources::Project.index_refresh_every = 5

    get "/admin/resources/projects"

    expect(listing["data-resource-refresh-interval-value"]).to eq("5000")
  end

  [nil, false, 0, 0.seconds].each do |value|
    it "doesn't refresh the records with #{value.inspect}" do
      Avo::Resources::Project.index_refresh_every = value

      get "/admin/resources/projects"

      expect(listing).to be_present
      expect(listing["data-controller"]).to be_nil
    end
  end

  # The search replaces the list with one rendered for the searched URL, so the next reload searches too.
  it "keeps refreshing the searched records" do
    Avo::Resources::Project.index_refresh_every = 10.seconds
    create :project, name: "Alpha release"

    get "/admin/resources/projects?q=release&page=1", headers: search_headers

    expect(response).to have_http_status(:ok)
    replacement = Nokogiri::HTML(response.body).at_css('turbo-stream[action="replace"][target="projects_body_content"] template')
    list = replacement.at_css("#projects_body_content")
    expect(list["data-controller"]).to eq("resource-refresh")
    expect(list["data-resource-refresh-url-value"]).to eq("/admin/resources/projects?q=release&page=1")
    expect(list.text).to include("Alpha release")
  end

  it "refreshes the records inside the lazy-loaded frame" do
    original_loading = Avo::Resources::Project.index_view_loading
    Avo::Resources::Project.index_view_loading = :lazy
    Avo::Resources::Project.index_refresh_every = 10.seconds

    get "/admin/resources/projects"
    expect(listing).to be_nil

    get "/admin/resources/projects", headers: {"Turbo-Frame" => "projects_index"}
    expect(listing["data-controller"]).to eq("resource-refresh")
    expect(listing["data-resource-refresh-url-value"]).to eq("/admin/resources/projects")
  ensure
    Avo::Resources::Project.index_view_loading = original_loading
  end

  describe "in an association panel" do
    let(:team) { create :team }
    let!(:review) { create :review, reviewable: team, body: "Panel review" }
    let(:panel_path) { "/admin/resources/teams/#{team.to_param}/reviews?turbo_frame=has_many_field_show_reviews" }

    it "refreshes the records from the panel's URL" do
      Avo::Resources::Review.index_refresh_every = 15.seconds

      get panel_path

      expect(listing("reviews_body_content")["data-controller"]).to eq("resource-refresh")
      expect(listing("reviews_body_content")["data-resource-refresh-url-value"]).to eq(panel_path)
      expect(listing("reviews_body_content")["data-resource-refresh-interval-value"]).to eq("15000")
    end

    it "answers a reload with the panel's records" do
      Avo::Resources::Review.index_refresh_every = 15.seconds
      create :review, body: "Another team's review"

      get panel_path, headers: search_headers

      expect(response).to have_http_status(:ok)
      replacement = Nokogiri::HTML(response.body).at_css('turbo-stream[action="replace"][target="reviews_body_content"] template')
      list = replacement.at_css("#reviews_body_content")
      expect(list["data-resource-refresh-url-value"]).to eq(panel_path)
      expect(list.text).to include("Panel review")
      expect(list.text).not_to include("Another team's review")
    end

    it "passes the panel's parent to the block" do
      Avo::Resources::Review.index_refresh_every = -> { 20.seconds if parent_record.present? && parent_resource.is_a?(Avo::Resources::Team) }

      get panel_path
      expect(listing("reviews_body_content")["data-resource-refresh-interval-value"]).to eq("20000")

      get "/admin/resources/reviews"
      expect(listing("reviews_body_content")).to be_present
      expect(listing("reviews_body_content")["data-controller"]).to be_nil
    end
  end
end
