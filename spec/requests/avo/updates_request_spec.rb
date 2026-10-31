require "rails_helper"

RSpec.describe "Status page updates", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "flags Avo as behind when HQ has a newer release" do
    allow(Avo::Services::GemVersions).to receive(:latest).and_return("avo" => "999.0.0")

    get "/admin/status"

    expect(response.body).to include("status-page__plugin-badge--behind", "Behind: 999.0.0 is available")
  end

  it "lists release notes oldest first, marking what is installed" do
    allow(Avo::Services::GemVersions).to receive(:releases_since).and_return([
      {"gem" => "avo", "version" => Avo::VERSION, "released_at" => "2026-01-01T00:00:00Z", "body_html" => "<p>Shipped</p><script>alert(1)</script>"},
      {"gem" => "avo", "version" => "999.0.0", "released_at" => "2026-02-01T00:00:00Z", "body" => "Coming"}
    ])

    get "/admin/updates"

    expect(response.body).to match(/#{Regexp.escape(Avo::VERSION)}.*Installed.*999\.0\.0.*Available/mo)
    expect(response.body).to include("<p>Shipped</p>").and include("Coming")
    expect(response.body).not_to include("<script>alert(1)</script>")
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
