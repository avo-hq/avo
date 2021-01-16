require 'rails_helper'

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:user) { create :user }
  let(:team) { create :team }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe 'index?' do
    subject { get :index, params: { resource_name: 'teams' } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe '.new' do
    subject { get :new, params: { resource_name: 'teams' } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe 'create?' do
    subject { post :create, params: { resource_name: 'teams', resource: { name: 'Avocado team' } } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe 'show?' do
    subject { get :show, params: { resource_name: 'teams', id: team.id } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe 'update?' do
    subject { put :update, params: { resource_name: 'teams', id: team.id, resource: { name: 'All about avocados' } } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe 'edit?' do
    subject { get :edit, params: { resource_name: 'teams', id: team.id } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
  end

  describe 'destroy?' do
    subject { delete :destroy, params: { resource_name: 'teams', id: team.id } }

    it 'fails' do
      expect { subject }.to raise_error ActionController::RoutingError
    end
    it 'destroys the user' do
      subject

      expect(User.where(id: team.id).first).to be nil
    end
  end
end
