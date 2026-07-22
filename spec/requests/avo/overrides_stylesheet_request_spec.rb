require "rails_helper"

RSpec.describe "Avo overrides stylesheet", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  it "loads after the Avo application stylesheet" do
    get "/admin/failed_to_load"

    stylesheets = Nokogiri::HTML(response.body)
      .css('head link[rel="stylesheet"]')
      .filter_map { |link| link["href"] }

    application_index = stylesheets.index { |path| path.include?("avo/application") }
    overrides_index = stylesheets.index { |path| path.include?("avo-overrides") }

    expect(response).to have_http_status(:ok)
    expect(application_index).not_to be_nil
    expect(overrides_index).not_to be_nil
    expect(overrides_index).to be > application_index
  end
end
