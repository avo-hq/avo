require "rails_helper"

# Server half of the browser-timezone feature: the browser-timezone Stimulus
# controller mirrors the viewer's IANA zone into `avo.browser_timezone`, and
# BaseApplicationController#render_to_body renders the response in it. The
# one-shot `avo.timezone_changed` cookie (set right before the controller's
# Turbo reload) makes the reloaded page announce the change once via flash.
#
# The zone is scoped to rendering only. App code running in the action itself
# keeps the app's configured zone, so `Time.zone.local` in an action's `handle`
# still means what it means everywhere else in Rails.
RSpec.describe "Browser timezone", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:path) { "/admin/failed_to_load" }

  before do
    login_as admin_user
    Avo.configuration.use_browser_timezone = true
    allow(Time).to receive(:use_zone).and_call_original
  end

  # The config defaults off in the test environment (the first-load soft
  # reload would race every browser spec), so restore that after opting in.
  after { Avo.configuration.use_browser_timezone = false }

  it "is off by default in the test environment" do
    expect(Avo::Configuration.new.use_browser_timezone).to be false
  end

  it "renders the request in the cookie's zone" do
    cookies["avo.browser_timezone"] = "Europe/Bucharest"

    get path

    expect(response).to have_http_status(:ok)
    expect(Time).to have_received(:use_zone).with(ActiveSupport::TimeZone["Europe/Bucharest"])
  end

  it "announces the zone once when the changed cookie is present, and deletes it" do
    cookies["avo.browser_timezone"] = "Europe/Bucharest"
    cookies["avo.timezone_changed"] = "1"

    get path

    expect(response.body).to include("Dates and times are now displayed in your time zone (Europe/Bucharest).")

    # The one-shot cookie is deleted, so a plain follow-up shows no flash.
    expect(Array(response.headers["Set-Cookie"]).join).to include("avo.timezone_changed=;")
    get path
    expect(response.body).not_to include("Dates and times are now displayed")
  end

  # Regression: the zone used to be applied with an `around_action`, which wrapped
  # the whole request. App code running in the action then silently reinterpreted
  # `Time.zone`, so a `Time.zone.local` in an action's `handle` built a timestamp
  # in the viewer's zone instead of the app's. See avo-hq/avo#4703.
  it "leaves the action on the app's configured zone" do
    cookies["avo.browser_timezone"] = "Europe/Bucharest"

    zone_in_action = nil
    allow_any_instance_of(Avo::BaseApplicationController).to receive(:set_view).and_wrap_original do |original, *args|
      zone_in_action = Time.zone.name
      original.call(*args)
    end

    get path

    expect(response).to have_http_status(:ok)
    expect(zone_in_action).to eq Time.zone.name
    expect(zone_in_action).not_to eq "Bucharest"

    # Rendering still gets the viewer's zone.
    expect(Time).to have_received(:use_zone).with(ActiveSupport::TimeZone["Europe/Bucharest"])
  end

  it "restores the app zone after the response is rendered" do
    cookies["avo.browser_timezone"] = "Europe/Bucharest"
    app_zone = Time.zone.name

    get path

    expect(Time.zone.name).to eq app_zone
  end

  it "falls back to the app zone on a junk cookie without raising" do
    cookies["avo.browser_timezone"] = "Not/AZone"

    get path

    expect(response).to have_http_status(:ok)
    expect(Time).not_to have_received(:use_zone)
  end

  it "does nothing when the config is off" do
    Avo.configuration.use_browser_timezone = false
    cookies["avo.browser_timezone"] = "Europe/Bucharest"

    get path

    expect(response).to have_http_status(:ok)
    expect(Time).not_to have_received(:use_zone)
    expect(response.body).not_to include('data-controller="browser-timezone"')
  end

  it "attaches the Stimulus controller to the body when enabled" do
    get path

    expect(response.body).to include('data-controller="browser-timezone"')
  end
end
