require 'rails_helper'

class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where(active: true)
      end
    end
  end
end

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:regular_user) { create :user }
  let(:admin_user) { create :user, roles: { admin: true } }
  let!(:active_user) { create :user, first_name: 'active user', active: true }
  let!(:inactive_user) { create :user, first_name: 'inactive user', active: false }
  let(:dummy_user) { create :user }
  let(:resource_ids) { parsed_response['resources'].collect { |i| i['id'] } }
  let(:project) { create :project }

  before do
    project.users << active_user
    project.users << inactive_user
  end

  before :each do
    sign_in user

    subject
  end

  describe '.index' do
    subject { get :index, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      let(:user) { regular_user }

      it 'returns the scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).not_to include inactive_user.id
      end
    end

    context 'when user is admin' do
      let(:user) { admin_user }

      it 'returns the scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).to include inactive_user.id
      end
    end

    describe 'with via_resource_name' do
      subject { get :index, params: { resource_name: 'users', via_resource_name: 'projects', via_resource_id: project.id, via_relationship: 'users' } }

      context 'when user is not admin' do
        let(:user) { regular_user }

        it 'returns the scoped results' do
          expect(resource_ids).to include active_user.id
          expect(resource_ids).not_to include inactive_user.id
        end
      end

      context 'when user is admin' do
        let(:user) { admin_user }

        it 'returns the scoped results' do
          expect(resource_ids).to include active_user.id
          expect(resource_ids).to include inactive_user.id
        end
      end
    end
  end

  describe '.resource_search' do
    subject { get :resource_search, params: { resource_name: 'users', q: 'active' } }

    context 'when user is not admin' do
      let(:user) { regular_user }

      it 'returns scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).not_to include inactive_user.id
      end
    end

    context 'when user is admin' do
      let(:user) { admin_user }

      it 'returns scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).to include inactive_user.id
      end
    end
  end

  describe '.search' do
    subject { get :search, params: { q: 'active' } }
    let(:resource_ids) { parsed_response['resources'].find { |group| group['label'] == 'User' }['resources'].collect { |i| i['id'] } }

    context 'when user is not admin' do
      let(:user) { regular_user }

      it 'returns scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).not_to include inactive_user.id
      end
    end

    context 'when user is admin' do
      let(:user) { admin_user }

      it 'returns scoped results' do
        expect(resource_ids).to include active_user.id
        expect(resource_ids).to include inactive_user.id
      end
    end
  end
end
