require "rails_helper"

# `?set_locale=` writes Avo.configuration.locale, which every later request of
# every user reads, so it must only take a known locale and only after
# authentication (GHSA-h7x6-9mqf-vgmx).
RSpec.describe "Locale params", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:page_path) { "/admin/failed_to_load" }

  before { login_as admin_user }

  around do |example|
    original_locale = Avo.configuration.locale
    Avo.configuration.locale = nil
    example.run
  ensure
    Avo.configuration.locale = original_locale
  end

  it "ignores an unknown set_locale" do
    get page_path, params: {set_locale: "zz"}

    expect(response).to have_http_status(:ok)
    expect(Avo.configuration.locale).to be_nil
  end

  it "applies a valid set_locale to later requests" do
    get page_path, params: {set_locale: "de"}
    get page_path

    expect(response.body).to include "Laden fehlgeschlagen"
  end

  it "ignores set_locale on a request authentication rejects" do
    original_authenticate = Avo.configuration.authenticate
    Avo.configuration.authenticate = proc { redirect_to "/" }

    get page_path, params: {set_locale: "de"}

    expect(response).to redirect_to "/"
    expect(Avo.configuration.locale).to be_nil
  ensure
    Avo.configuration.authenticate = original_authenticate
  end

  it "ignores an unknown force_locale" do
    get page_path, params: {force_locale: "zz"}

    expect(response).to have_http_status(:ok)
  end
end
