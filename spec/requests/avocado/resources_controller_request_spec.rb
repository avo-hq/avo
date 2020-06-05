require 'rails_helper'

RSpec.describe 'ResourcesControllers', type: :request do
  context '.index' do
    describe 'with empty response' do
      it 'returns empty resources response' do
        get '/avocado/avocado-api/users'

        expect(response).to have_http_status(200)
        expect(parsed_response).to eql({
          meta: {
            per_page_steps: [24, 48, 72]
          },
          per_page: 24,
          resources: [],
          total_pages: 0
        }.deep_stringify_keys)
      end
    end
  end

  context '.edit' do
    describe 'with empty required field' do
      let!(:user) { create :user }

      it 'throws error when empty required field sent' do
        expect {
          put "/avocado/avocado-api/users/#{user.id}", params: {
            resource: {
              name: 'John'
            }
          }.to_param
        }.not_to raise_error

        expect(user.reload.name).to eql 'John'
      end

      it 'saves resource when valid field send' do
        expect {
          put "/avocado/avocado-api/users/#{user.id}", params: {
              resource: {
                name: ''
              }
            }.to_param
          }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank"
      end
    end
  end
end
