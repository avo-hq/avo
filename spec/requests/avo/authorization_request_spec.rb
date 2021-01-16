require 'rails_helper'

RSpec.describe "Authorizations", type: :request do
  let(:user) { create :user }

  before do
    login_as user
  end

  it "creates a Widget and redirects to the Widget's page" do
    get "/avo/resources/users"
    expect(response).to render_template(:index)

    # post "/widgets", :params => { :widget => {:name => "My Widget"} }

    # expect(response).to redirect_to(assigns(:widget))
    # follow_redirect!

    # expect(response).to render_template(:show)
    # expect(response.body).to include("Widget was successfully created.")
  end
end
