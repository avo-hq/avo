require "rails_helper"

RSpec.describe "AppearanceSettings", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before do
    login_as admin_user
  end

  describe "PATCH /admin/appearance_settings" do
    context "when no save_settings block is configured" do
      before do
        allow(Avo.configuration.appearance).to receive(:save_settings_block).and_return(nil)
      end

      it "returns unprocessable_entity" do
        patch "/admin/appearance_settings", params: {color_scheme: "dark"}

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
        patch "/admin/appearance_settings", params: {color_scheme: "dark", neutral: "slate", accent: "blue"}

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["ok"]).to be true
      end

      it "passes permitted params to the save block" do
        patch "/admin/appearance_settings", params: {color_scheme: "dark", neutral: "slate", accent: "blue"}

        expect(response).to have_http_status(:ok)
      end

      it "passes only the attributes sent in a JSON body (partial update)" do
        patch "/admin/appearance_settings", params: {color_scheme: "dark"}, as: :json

        expect(response).to have_http_status(:ok)
        expect(saved_settings).to eq({color_scheme: "dark"})
      end

      it "saves a valid density and ignores invalid or locked picks" do
        patch "/admin/appearance_settings", params: {density: "tight"}, as: :json
        expect(saved_settings).to eq(density: "tight")

        patch "/admin/appearance_settings", params: {density: "invalid"}, as: :json
        expect(saved_settings).to eq(density: "tight")

        allow(Avo.configuration.appearance).to receive(:density_picker?).and_return(false)
        patch "/admin/appearance_settings", params: {density: "relaxed"}, as: :json
        expect(saved_settings).to eq(density: "tight")
      end

      it "saves valid roundness without overwriting density and ignores invalid or disabled picks" do
        patch "/admin/appearance_settings", params: {density: "relaxed", roundness: "square"}, as: :json
        expect(saved_settings).to eq(density: "relaxed", roundness: "square")

        patch "/admin/appearance_settings", params: {roundness: "invalid"}, as: :json
        expect(saved_settings).to eq(density: "relaxed", roundness: "square")

        allow(Avo.configuration.appearance).to receive(:roundness_picker?).and_return(false)
        patch "/admin/appearance_settings", params: {roundness: "tight"}, as: :json
        expect(saved_settings).to eq(density: "relaxed", roundness: "square")
      end
    end
  end
end
