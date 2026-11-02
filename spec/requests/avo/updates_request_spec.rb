require "rails_helper"

RSpec.describe "Status page updates", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  # The dummy app's tmp/ is shared with a running dev server, whose update these specs must not wipe.
  let(:update_dir) { Pathname.new(Dir.mktmpdir) }

  before do
    login_as admin_user
    allow(Avo::Services::Updater).to receive(:dir).and_return(update_dir)
  end

  after { FileUtils.rm_rf(update_dir) }

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

    expect(response.body).to match(/Available.*999\.0\.0.*Installed.*#{Regexp.escape(Avo::VERSION)}/mo)
    expect(response.body).to include("<p>Shipped</p>").and include("Coming").and include("<p>GitHub notes</p>")
    expect(response.body).not_to include("<script>alert(1)</script>")
    expect(response.body).to include("/admin/updates?page=2")
    expect(response.body).not_to match(/>\s*Newer\s*</)
  end

  it "shows a release's UTC date in every time zone, and no date when HQ sends a bad one" do
    allow(Avo::Services::GemVersions).to receive(:releases).and_return(
      "releases" => [
        {"gem" => "avo", "version" => "999.0.0", "released_at" => "2026-02-01T00:00:00Z"},
        {"gem" => "avo", "version" => "998.0.0", "released_at" => "not a date"}
      ],
      "next_page" => nil
    )

    Time.use_zone("Pacific Time (US & Canada)") { get "/admin/updates" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("February 01, 2026").and include("998.0.0")
    expect(response.body).not_to include("January 31, 2026")
  end

  it "offers Update all only when a release is available" do
    allow(Avo::Services::Updater).to receive(:allowed?).and_return(true)
    allow(Avo::Services::GemVersions).to receive(:releases).and_return(
      {"releases" => [{"gem" => "avo", "version" => "999.0.0"}], "next_page" => nil},
      {"releases" => [{"gem" => "avo", "version" => Avo::VERSION}], "next_page" => nil}
    )

    get "/admin/updates"
    expect(response.body).to include("Update all")

    get "/admin/updates"
    expect(response.body).not_to include("Update all")
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
    allow(Process).to receive(:spawn).and_return(Process.pid)
    allow(Process).to receive(:detach)

    post "/admin/updates/run"

    expect(Process).to have_received(:spawn).with("sh", "-c", a_string_including("bin/rails avo:update"), any_args)
    expect(response.body).to include("Updating", "poll-frame")
  end

  it "starts one update when two requests arrive together" do
    allow(Process).to receive(:spawn) do
      sleep 0.05
      Process.pid
    end
    allow(Process).to receive(:detach)

    2.times.map { Thread.new { Avo::Services::Updater.start } }.each(&:join)

    expect(Process).to have_received(:spawn).once
  end

  it "offers Update all again after restarting from a finished update" do
    allow(Avo::Services::Updater).to receive(:allowed?).and_return(true)
    allow(FileUtils).to receive(:touch)
    File.write(update_dir.join("pid"), Process.pid)
    File.write(update_dir.join("exit_status"), "0")

    post "/admin/updates/restart"
    get "/admin/updates/progress"

    expect(response.body).to include("Update all")
    expect(response.body).not_to include("Restart app")
  end

  it "reports a run that died without an exit status as failed, so the page stops waiting" do
    dead_pid = Process.spawn("true")
    Process.wait(dead_pid)
    File.write(update_dir.join("pid"), dead_pid)

    get "/admin/updates/progress"

    expect(response.body).to include("Update failed")
    expect(response.body).not_to include("poll-frame")
  end
end
