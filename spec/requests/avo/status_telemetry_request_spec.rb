require "rails_helper"

RSpec.describe "Status page telemetry", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "shows the telemetry payload when building Avo" do
    stub_const("Avo::IN_DEVELOPMENT", true)
    allow(Avo.configuration).to receive(:license_key).and_return("test-license-key")

    get "/admin/avo_private/status"

    expect(response.body).to include("Telemetry", "resources_count", "test-license-key", "install_id")
  end

  it "hides it from apps that install Avo" do
    stub_const("Avo::IN_DEVELOPMENT", false)

    get "/admin/avo_private/status"

    expect(response.body).not_to include("resources_count")
  end
end
