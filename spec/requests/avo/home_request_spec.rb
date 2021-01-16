require 'rails_helper'

RSpec.describe 'Home', type: :request do
  let(:admin_user) { create :user, roles: { 'admin': true } }

  before :each do
    stub_pro_license_request
  end

  before do
    login_as admin_user
  end

  it 'renders the homepage' do
    get '/avo'
    expect(response).to render_template('avo/home/hotwire')
    expect(response.body).to include 'Avocadelicious', 'hey hotwire', 'Hotwire 2'
  end
end
