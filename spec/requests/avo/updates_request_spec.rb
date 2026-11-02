require "rails_helper"

RSpec.describe "Status page updates", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "flags Avo as behind when HQ has a newer release" do
    allow(Avo::Services::GemVersions).to receive(:latest).and_return("avo" => "999.0.0")

    get "/admin/status"

    expect(response.body).to include("status-page__plugin-badge--behind", "Behind: 999.0.0 is available")
  end

  it "lists the release history newest first, marking what is installed, and pages to older notes" do
    allow(Avo::Services::GemVersions).to receive(:releases).with(page: 1).and_return(
      "releases" => [
        {"gem" => "avo", "version" => "999.0.0", "released_at" => "2026-02-01T00:00:00Z", "body" => "Coming", "description_html" => "<p>GitHub notes</p>"},
        {"gem" => "avo", "version" => Avo::VERSION, "released_at" => "2026-01-01T00:00:00Z", "body_html" => "<p>Shipped</p><script>alert(1)</script>"}
      ],
      "next_page" => 2
    )

    get "/admin/updates"

    expect(response.body).to match(/999\.0\.0.*Available.*#{Regexp.escape(Avo::VERSION)}.*Installed/mo)
    expect(response.body).to include("<p>Shipped</p>").and include("Coming").and include("<p>GitHub notes</p>")
    expect(response.body).not_to include("<script>alert(1)</script>")
    expect(response.body).to include("/admin/updates?page=2")
    expect(response.body).not_to include("Newer")
  end

  it "asks HQ again after an empty answer instead of keeping it for an hour" do
    allow(Rails.env).to receive(:test?).and_return(false)
    allow(Avo).to receive(:cache_store).and_return(ActiveSupport::Cache::MemoryStore.new)
    stub_request(:get, %r{\Ahttps://avohq\.io/releases\.json}).to_return(
      {body: {releases: []}.to_json},
      {body: {releases: [{gem: "avo", version: "999.0.0"}], next_page: nil}.to_json}
    )

    expect(Avo::Services::GemVersions.releases["releases"]).to be_empty
    expect(Avo::Services::GemVersions.releases["releases"].first["version"]).to eq("999.0.0")
  end

  it "refuses to run the update outside development" do
    expect(Process).not_to receive(:spawn)

    post "/admin/updates/run"

    expect(response).to have_http_status(:forbidden)
  end

  it "starts avo:update in the background in development and reports progress" do
    allow(Avo::Services::Updater).to receive(:allowed?).and_return(true)
    allow(Process).to receive(:spawn).and_return(12345)
    allow(Process).to receive(:detach)
    FileUtils.rm_rf(Rails.root.join("tmp", "avo_update"))

    post "/admin/updates/run"

    expect(Process).to have_received(:spawn).with("sh", "-c", a_string_including("bin/rails avo:update"), any_args)
    expect(response.body).to include("Updating", "poll-frame")
  ensure
    FileUtils.rm_rf(Rails.root.join("tmp", "avo_update"))
  end
end
