require 'rails_helper'

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:user) { create :user }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  before :all do
    class UserPolicy < ApplicationPolicy
      def index?
        true
      end

      def update?
        true
      end
    end

    class PostPolicy < ApplicationPolicy
      def index?
        true
      end

      def update?
        true
      end
    end
  end

  after :all do
    class UserPolicy < ApplicationPolicy
      def index?
        false
      end

      def update?
        false
      end
    end

    class PostPolicy < ApplicationPolicy
      def index?
        false
      end

      def update?
        false
      end
    end
  end

  context '.index' do
    describe 'with empty response' do
      it 'returns empty resources response' do
        get :index, params: { resource_name: 'posts' }

        expect(response).to have_http_status(200)
        expect(parsed_response).to eql({
          meta: {
            authorization: { create: false, edit: true, destroy: false, show: false, update: true },
            per_page_steps: [12, 24, 48, 72],
            available_view_types: ['grid', 'table'],
            default_view_type: 'grid',
            translation_key: nil,
          },
          per_page: 24,
          resources: [],
          success: true,
          total_pages: 0
        }.deep_stringify_keys)
      end
    end
  end

  context '.update' do
    describe 'with empty required field' do
      let!(:user) { create :user }

      it 'throws error when empty required field sent' do
        expect {
          put :update, params: {
            resource_name: 'users',
            id: user.id,
            resource: {
              first_name: 'John'
            }
          }
        }.not_to raise_error

        expect(user.reload.first_name).to eql 'John'
      end

      it 'saves resource when valid field send' do
        expect {
          put :update, params: {
            resource_name: 'users',
            id: user.id,
            resource: {
              first_name: ''
            }
          }
        }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: First name can't be blank"
      end
    end
  end
end
