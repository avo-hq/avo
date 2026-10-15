require "rails_helper"

RSpec.describe "Festivity rendering", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:html_tag) { response.body[/<html\b[^>]*>/] }
  let(:festivity_link) { %r{<link\b[^>]*href="[^"]*/avo/festivities/christmas[^"]*\.css"[^>]*>} }

  before { login_as admin_user }

  around do |example|
    original = Avo.configuration.instance_variable_get(:@festivity)
    example.run
  ensure
    Avo.configuration.festivity = original
  end

  context "when :christmas is active" do
    before { Avo.configuration.festivity = :christmas }

    it "links the Turbo-tracked stylesheet and puts the class on <html>" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(festivity_link)
      expect(response.body[festivity_link]).to include('data-turbo-track="reload"')
      expect(html_tag).to include("festivity-christmas")
    end

    it "renders the garland inside the navbar" do
      get "/admin/failed_to_load"

      expect(response.body).to match(%r{<nav\b[^>]*top-navbar.*<div class="festivity-garland" aria-hidden="true"></div>}m)
    end

    context "when the user has opted out" do
      before { admin_user.update!(avo_preferences: {"appearance" => {"festivity_christmas" => "off"}}) }

      it "keeps the stylesheet link but leaves the class off <html>" do
        get "/admin/failed_to_load"

        expect(response.body).to match(festivity_link)
        expect(html_tag).not_to include("festivity-christmas")
      end

      it "reads the opt-out from the cookie under cookie persistence" do
        allow(Avo.configuration.appearance).to receive(:persistence).and_return(:cookie)
        cookies["festivity_christmas"] = "off"

        get "/admin/failed_to_load"

        expect(response.body).to match(festivity_link)
        expect(html_tag).not_to include("festivity-christmas")
      end

      it "offers the toggle to turn the decorations back on" do
        get "/admin/failed_to_load"

        expect(response.body).to include('data-festivity-decorations="on"')
      end
    end

    context "when :festivity is locked" do
      before do
        allow(Avo.configuration.appearance).to receive(:festivity_locked?).and_return(true)
        admin_user.update!(avo_preferences: {"appearance" => {"festivity_christmas" => "off"}})
      end

      it "ignores the opt-out and renders no toggle" do
        get "/admin/failed_to_load"

        expect(html_tag).to include("festivity-christmas")
        expect(response.body).not_to include("data-festivity-decorations")
      end
    end
  end

  context "when the festivity is nil" do
    before { Avo.configuration.festivity = nil }

    it "renders neither the stylesheet, the class nor the garland" do
      get "/admin/failed_to_load"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(festivity_link)
      expect(html_tag).not_to include("festivity-")
      expect(response.body).not_to include("festivity-garland")
      expect(response.body).not_to include("data-festivity-decorations")
    end
  end

  context "when a lambda decides" do
    it "renders the festivity when it returns :christmas" do
      Avo.configuration.festivity = -> { :christmas }

      get "/admin/failed_to_load"

      expect(response.body).to match(festivity_link)
      expect(html_tag).to include("festivity-christmas")
    end

    it "renders nothing when it returns nil" do
      Avo.configuration.festivity = -> {}

      get "/admin/failed_to_load"

      expect(response.body).not_to match(festivity_link)
      expect(html_tag).not_to include("festivity-")
      expect(response.body).not_to include("festivity-garland")
    end

    it "is evaluated once per request" do
      calls = 0
      Avo.configuration.festivity = -> {
        calls += 1
        :christmas
      }

      get "/admin/failed_to_load"
      expect(calls).to eq(1)

      get "/admin/failed_to_load"
      expect(calls).to eq(2)
    end
  end
end
