require "rails_helper"

# The locale selector stores each viewer's language in a cookie, so switching
# never touches Avo.configuration.locale (which `?set_locale=` mutates for the
# whole process). These specs cover the switch endpoint and the precedence
# `set_avo_locale` applies on every later request.
RSpec.describe "Locale selector", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:cookie_name) { "avo.locale" }
  let(:page_path) { "/admin/failed_to_load" }

  before { login_as admin_user }

  around do |example|
    original = Avo.configuration.locale_selector
    example.run
  ensure
    Avo.configuration.locale_selector = original
    Avo.configuration.locale = nil
  end

  def html_lang
    Nokogiri::HTML(response.body).at_css("html")["lang"]
  end

  describe "PATCH /admin/locale" do
    it "stores a valid locale in the cookie and redirects back" do
      patch "/admin/locale", params: {locale: "ro"}, headers: {"HTTP_REFERER" => "http://www.example.com/admin/resources/users"}

      expect(response).to redirect_to("http://www.example.com/admin/resources/users")
      expect(cookies[cookie_name]).to eq "ro"
    end

    it "redirects to the Avo root when there is no referer" do
      patch "/admin/locale", params: {locale: "de"}

      expect(response).to have_http_status(:see_other)
      expect(cookies[cookie_name]).to eq "de"
    end

    it "does not store an unknown locale" do
      patch "/admin/locale", params: {locale: "xx"}

      expect(response).to have_http_status(:see_other)
      expect(cookies[cookie_name]).to be_blank
    end

    it "does not store a locale outside the configured list" do
      Avo.configuration.locale_selector = [:en, :ro]

      patch "/admin/locale", params: {locale: "de"}

      expect(cookies[cookie_name]).to be_blank
    end

    it "refuses the switch when the selector is disabled" do
      Avo.configuration.locale_selector = false

      patch "/admin/locale", params: {locale: "ro"}

      expect(response).to have_http_status(:not_found)
      expect(cookies[cookie_name]).to be_blank
    end

    it "never changes the global Avo locale" do
      patch "/admin/locale", params: {locale: "ro"}

      expect(Avo.configuration.locale).to be_nil
    end
  end

  describe "locale precedence" do
    it "applies the cookie on later requests" do
      patch "/admin/locale", params: {locale: "ro"}
      get page_path

      expect(html_lang).to eq "ro"
    end

    it "lets force_locale beat the cookie" do
      cookies[cookie_name] = "ro"
      get page_path, params: {force_locale: "de"}

      expect(html_lang).to eq "de"
    end

    it "lets set_locale beat the cookie" do
      cookies[cookie_name] = "ro"
      get page_path, params: {set_locale: "de"}

      expect(html_lang).to eq "de"
    end

    it "ignores a cookie for a locale outside the configured list" do
      Avo.configuration.locale_selector = [:en, :de]
      cookies[cookie_name] = "ro"
      get page_path

      expect(html_lang).to eq "en"
    end

    it "ignores a cookie for a locale that does not exist" do
      cookies[cookie_name] = "xx"
      get page_path

      expect(html_lang).to eq "en"
    end

    it "ignores the cookie when the selector is disabled" do
      Avo.configuration.locale_selector = false
      cookies[cookie_name] = "ro"
      get page_path

      expect(html_lang).to eq "en"
    end

    it "renders RTL for an RTL locale picked through the selector" do
      cookies[cookie_name] = "ar"
      get page_path

      expect(Nokogiri::HTML(response.body).at_css("html")["dir"]).to eq "rtl"
    end
  end
end
