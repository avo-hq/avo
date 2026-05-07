require "rails_helper"

RSpec.describe "ThemeSettings", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before do
    login_as admin_user
  end

  describe "PATCH /admin/theme_settings" do
    context "when no save_settings block is configured" do
      before do
        allow(Avo.configuration.appearance).to receive(:save_settings_block).and_return(nil)
      end

      it "returns unprocessable_entity" do
        patch "/admin/theme_settings", params: {color_scheme: "dark"}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["ok"]).to be false
      end
    end

    context "when save_settings block is configured" do
      let(:saved_settings) { {} }

      before do
        captured = saved_settings
        block = proc { captured.merge!(settings) }
        allow(Avo.configuration.appearance).to receive(:save_settings_block).and_return(block)
      end

      it "calls the save block and returns ok" do
        patch "/admin/theme_settings", params: {color_scheme: "dark", neutral: "slate", accent: "blue"}

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["ok"]).to be true
      end

      it "passes permitted params to the save block" do
        patch "/admin/theme_settings", params: {color_scheme: "dark", neutral: "slate", accent: "blue"}

        expect(response).to have_http_status(:ok)
      end

      it "passes only the attributes sent in a JSON body (partial update)" do
        patch "/admin/theme_settings", params: {color_scheme: "dark"}, as: :json

        expect(response).to have_http_status(:ok)
        expect(saved_settings).to eq({color_scheme: "dark"})
      end
    end
  end
end
