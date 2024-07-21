require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:admin_user) { create :user, roles: {'admin': true} }

  before do
    login_as admin_user
  end

  it "renders the homepage" do
    get "/admin"

    expect(response).to have_http_status(:redirect)
  end
end
