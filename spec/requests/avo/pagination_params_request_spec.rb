require "rails_helper"

RSpec.describe "Index pagination params", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:per_page) { Avo.configuration.per_page }

  before do
    login_as admin_user
    create_list :user, per_page + 1
  end

  it "falls back to the default per_page when it is not a number" do
    get "/admin/resources/users", params: {per_page: "abc"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("1-#{per_page}")
    expect(cookies[:per_page]).to eq per_page.to_s
  end

  it "falls back to the first page when page is not a number" do
    get "/admin/resources/users", params: {page: "abc"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("1-#{per_page}")
  end

  it "ignores a per_page cookie that is not a number" do
    cookies[:per_page] = "abc"

    get "/admin/resources/users"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("1-#{per_page}")
  end

  it "falls back to the defaults on an association index" do
    person = create :person, spouses: create_list(:spouse, Avo.configuration.via_per_page + 1)

    get "/admin/resources/people/#{person.id}/spouses",
      params: {turbo_frame: "has_many_field_show_spouses", per_page: "abc", page: "abc"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("1-#{Avo.configuration.via_per_page}")
  end
end
