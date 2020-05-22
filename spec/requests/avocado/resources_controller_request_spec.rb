require 'rails_helper'

RSpec.describe "ResourcesControllers", type: :request do
  describe ".index" do
    context 'with empty response' do
      it 'returns empty resources response' do
        get '/avocado/avocado-api/users'

        expect(response).to have_http_status(200)
        expect(parsed_response).to eql({ per_page: 25, resources: [], total_pages: 0 }.stringify_keys)
      end
    end
  end
end
