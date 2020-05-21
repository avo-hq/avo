require 'rails_helper'

RSpec.describe "ResourcesControllers", type: :request do

  # render_views

  describe ".index" do
    # let(:user) { create(:user, :with_shopify_shop) }
    # let(:channel) { user.channels.first }
    # let(:app) { user.two_tap_apps.first }
    # let(:cart) { create(:two_tap_cart, channel: channel) }

    before :each do
      # sign_in user
    end

    context 'without purchases' do
      it 'returns http success' do
        get '/avocado/avocado-api/users'

        expect(response).to have_http_status(200)
        expect(parsed_response).to eql({ per_page: 25, resources: [], total_pages: 0 }.stringify_keys)

        # expect(assigns(:purchases)).not_to be_nil
        # expect(assigns(:purchases)).to be_empty
      end
    end
  end
end
