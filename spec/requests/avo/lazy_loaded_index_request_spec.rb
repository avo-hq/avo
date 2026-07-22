require "rails_helper"

RSpec.describe "Lazy-loaded resource indexes", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before do
    login_as admin_user
  end

  around do |example|
    original_loading = Avo::Resources::Project.index_view_loading
    Avo::Resources::Project.index_view_loading = :lazy

    example.run
  ensure
    Avo::Resources::Project.index_view_loading = original_loading
  end

  it "renders the resource header without running the index query" do
    project = create :project, name: "Deferred project"
    expect(Avo::Resources::Project).not_to receive(:query_scope)

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Projects")
    expect(response.body).to match(/<turbo-frame[^>]+id="projects_index"/)
    expect(response.body).to include('src="/admin/resources/projects"')
    expect(response.body).to include("Loading projects")
    expect(response.body).not_to include(project.name)
    expect(response.body).not_to include("avo/view_types/table_component")
  end

  it "loads the table inside the deferred frame" do
    project = create :project, name: "Deferred project"
    expect(Avo::Resources::Project).to receive(:query_scope).and_call_original

    get "/admin/resources/projects", headers: {"Turbo-Frame" => "projects_index"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/<turbo-frame[^>]+id="projects_index"/)
    expect(response.body).to include("avo/view_types/table_component")
    expect(response.body).to include(project.name)
    expect(response.body).not_to include("Loading projects")
  end

  it "keeps eager loading as the default" do
    Avo::Resources::Project.index_view_loading = :eager
    project = create :project, name: "Eager project"

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(project.name)
    expect(response.body).not_to include('turbo-frame id="projects_index"')
  end

  it "loads alternate index view types inside the same frame" do
    original_loading = Avo::Resources::User.index_view_loading
    Avo::Resources::User.index_view_loading = :lazy

    get "/admin/resources/users",
      params: {view_type: "grid"},
      headers: {"Turbo-Frame" => "users_index"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/<turbo-frame[^>]+id="users_index"/)
    expect(response.body).to include('class="grid-wrapper"')
  ensure
    Avo::Resources::User.index_view_loading = original_loading
  end

  it "keeps loading records eagerly for custom index components" do
    original_components = Avo::Resources::Project.components
    Avo::Resources::Project.components = {
      resource_index_component: Avo::ForTest::ResourceIndexComponent
    }
    expect(Avo::Resources::Project).to receive(:query_scope).and_call_original

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Custom index component here!")
  ensure
    Avo::Resources::Project.components = original_components
  end
end
