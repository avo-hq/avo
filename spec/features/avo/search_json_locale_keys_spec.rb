# frozen_string_literal: true

require "rails_helper"

RSpec.feature Avo::SearchController, type: :controller do
  describe "search JSON group keys" do
    let!(:user) { create :user, first_name: "Ada", last_name: "Lovelace" }

    around do |example|
      I18n.backend.store_translations(:de, {
        avo: {
          resource_translations: {
            user: {
              one: "Benutzer",
              other: "Benutzer"
            }
          }
        }
      })

      example.run
    ensure
      I18n.backend.reload!
    end

    it "keys groups by the stable route_key across locales" do
      english_payload = search_payload_for(locale: :en)
      german_payload = search_payload_for(locale: :de)

      expect(english_payload.keys).to include("users")
      expect(german_payload.keys).to include("users")
      expect(german_payload.keys).not_to include("benutzers")
      expect(german_payload.keys).to eq(english_payload.keys)
    end

    it "ships the translated plural label in the header value" do
      payload = search_payload_for(locale: :de)

      expect(payload.fetch("users").fetch("header")).to start_with("Benutzer")
    end

    def search_payload_for(locale:)
      get :show, params: {resource_name: "users", q: "Ada", force_locale: locale}

      expect(response).to have_http_status(:ok)
      JSON.parse(response.body)
    end
  end
end
