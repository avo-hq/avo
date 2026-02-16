require "rails_helper"

RSpec.describe "UserPreferences", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:preference_store) { {} }

  let(:user_preferences_config) do
    store = preference_store
    {
      load: ->(user:, request:) { store[user.id] || {} },
      save: ->(user:, request:, key:, value:, preferences:) { store[user.id] = preferences }
    }
  end

  describe "GET /admin/user_preference (show)" do
    context "when user_preferences is configured and user is signed in" do
      before do
        login_as admin_user
        Avo.configuration.user_preferences = user_preferences_config
        preference_store[admin_user.id] = {"color_scheme" => "dark", "theme" => "slate"}
      end

      after do
        Avo.configuration.user_preferences = nil
      end

      it "returns 200 with current preferences" do
        get "/admin/user_preference"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["preferences"]).to include("color_scheme" => "dark", "theme" => "slate")
      end
    end

    context "when user_preferences is not configured" do
      before do
        login_as admin_user
        Avo.configuration.user_preferences = nil
      end

      it "returns 404" do
        get "/admin/user_preference"

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("not_configured")
      end
    end
  end

  describe "PATCH /admin/user_preference (update)" do
    context "when user_preferences is configured and user is signed in" do
      before do
        login_as admin_user
        Avo.configuration.user_preferences = user_preferences_config
      end

      after do
        Avo.configuration.user_preferences = nil
      end

      it "returns 200 and saves preferences" do
        patch "/admin/user_preference",
          params: {preferences: {color_scheme: "dark", theme: "slate", accent_color: "blue"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["status"]).to eq("ok")
        expect(preference_store[admin_user.id]).to include("color_scheme" => "dark")
      end

      it "silently ignores unregistered keys" do
        patch "/admin/user_preference",
          params: {preferences: {color_scheme: "dark", unknown_key: "value"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)

        saved = preference_store[admin_user.id]
        expect(saved).to have_key("color_scheme")
        expect(saved).not_to have_key("unknown_key")
      end

      it "accepts registered custom keys" do
        Avo.configuration.user_preference_keys = [:sidebar_collapsed]

        patch "/admin/user_preference",
          params: {preferences: {sidebar_collapsed: "true"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)

        Avo.configuration.user_preference_keys = []
      end
    end

    context "when user_preferences is not configured" do
      before do
        login_as admin_user
        Avo.configuration.user_preferences = nil
      end

      it "returns 404" do
        patch "/admin/user_preference",
          params: {preferences: {color_scheme: "dark"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("not_configured")
      end
    end

    context "when no user is signed in" do
      before do
        Avo.configuration.user_preferences = user_preferences_config
      end

      after do
        Avo.configuration.user_preferences = nil
      end

      # The controller returns 401 JSON for unauthenticated requests, but in the
      # dummy app Devise's `authenticate :user` route constraint intercepts the
      # request first and redirects to sign-in before the controller ever runs.
      it "redirects to sign-in (Devise intercepts before controller)" do
        patch "/admin/user_preference",
          params: {preferences: {color_scheme: "dark"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when save callback raises an error" do
      before do
        login_as admin_user
        Avo.configuration.user_preferences = {
          load: ->(user:, request:) { {} },
          save: ->(user:, request:, key:, value:, preferences:) { raise "Storage failure" }
        }
      end

      after do
        Avo.configuration.user_preferences = nil
      end

      it "returns 422 with error details" do
        patch "/admin/user_preference",
          params: {preferences: {color_scheme: "dark"}}.to_json,
          headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]).to include("Storage failure")
      end
    end
  end
end
