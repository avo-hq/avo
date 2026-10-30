require "rails_helper"

# A user may only ever act for the teams they belong to, whatever id the session, the URL or the switcher sends.
RSpec.describe "Tenancy", type: :request do
  let(:apple) { create :team, name: "Apple" }
  let(:google) { create :team, name: "Google" }
  let(:amazon) { create :team, name: "Amazon" }
  let(:foreign) { create :team, name: "Foreign" }
  let(:user) { create :user, roles: {admin: true}, teams: [apple, google, amazon] }
  let(:page_path) { "/admin/failed_to_load" }

  before { login_as user }

  around do |example|
    Avo.configuration.tenancy = {tenants: -> { current_user.teams.order(:id) }}
    example.run
  ensure
    Avo.configuration.tenancy = nil
  end

  def current_tenant_title
    get page_path
    Nokogiri::HTML(response.body).at_css(".tenant-switcher__trigger .tenant-switcher__title")&.text
  end

  it "starts on the user's first team and switches to another of theirs" do
    expect(current_tenant_title).to eq "Apple"

    patch "/admin/tenant", params: {id: google.id}

    expect(response).to have_http_status(:see_other)
    expect(current_tenant_title).to eq "Google"
  end

  it "answers a foreign and an unknown id the same way and keeps the current team" do
    patch "/admin/tenant", params: {id: foreign.id}
    foreign_response = [response.status, response.body]

    patch "/admin/tenant", params: {id: 0}

    expect(foreign_response).to eq [404, ""]
    expect([response.status, response.body]).to eq [404, ""]
    expect(current_tenant_title).to eq "Apple"
  end

  it "drops a team on the next request once the membership is removed" do
    patch "/admin/tenant", params: {id: google.id}
    TeamMembership.where(user:, team: google).delete_all

    expect(current_tenant_title).to eq "Apple"
  end

  it "shows the no-account page instead of the admin when the user belongs to no team" do
    TeamMembership.where(user:).delete_all

    get "/admin/resources/teams"

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("No account to show")
    expect(response.body).not_to include("top-navbar")
  end

  it "refuses a switch without a CSRF token" do
    ActionController::Base.allow_forgery_protection = true

    expect { patch "/admin/tenant", params: {id: google.id} }.to raise_error(ActionController::InvalidAuthenticityToken)
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  it "has no GET route for switching" do
    expect { get "/admin/tenant", params: {id: google.id} }.to raise_error(ActionController::RoutingError)
  end

  it "does not hand the stored team to the next user signed in on the same session" do
    patch "/admin/tenant", params: {id: google.id}

    login_as create(:user, roles: {admin: true}, teams: [apple, google])

    expect(current_tenant_title).to eq "Apple"
  end

  it "redirects to the current resource's index or the Avo root, never back to the referrer" do
    record_url = "http://www.example.com/admin/resources/teams/#{apple.id}"

    patch "/admin/tenant", params: {id: google.id, resource: "teams"}, headers: {"HTTP_REFERER" => record_url}
    expect(response).to redirect_to("/admin/resources/teams")

    patch "/admin/tenant", params: {id: apple.id, resource: "https://evil.example"}, headers: {"HTTP_REFERER" => record_url}
    expect(response).to redirect_to("/admin/")
  end

  it "announces the switch with the user and both teams" do
    events = []
    callback = ->(event) { events << event.payload }

    ActiveSupport::Notifications.subscribed(callback, "switch_tenant.avo") do
      patch "/admin/tenant", params: {id: google.id}
    end

    expect(events).to eq [{user:, from: apple, to: google}]
  end

  it "404s a route-based tenant the user does not belong to" do
    Avo.configuration.tenancy = {tenants: -> { current_user.teams }, strategy: :route}

    get page_path, params: {tenant_id: google.id}
    expect(response).to have_http_status(:ok)

    expect { get page_path, params: {tenant_id: foreign.id} }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
