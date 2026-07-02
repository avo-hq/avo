require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before do
    login_as admin_user
  end

  it "renders the homepage" do
    get "/admin"

    expect(response).to have_http_status(:redirect)
  end

  describe "GET /admin/failed_to_load" do
    it "renders humanized turbo_frame in the message" do
      get "/admin/failed_to_load", params: {
        turbo_frame: "has_many_field_show_memberships",
        src: "/admin/resources/fish"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Failed to load:")
      expect(response.body).to include("has many field show memberships")
    end

    it "uses a fallback label when turbo_frame is absent" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Failed to load:")
      expect(response.body).to include("this frame")
    end

    it "does not render the dev-only note outside development" do
      get "/admin/failed_to_load", params: {turbo_frame: "filter", src: "/admin/resources/fish"}

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("this link")
    end
  end
end
