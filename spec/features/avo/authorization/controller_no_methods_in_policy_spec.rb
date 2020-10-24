require 'rails_helper'

class TeamPolicy < ApplicationPolicy
end

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:user) { create :user }
  let(:dummy_team) { create :team }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe 'index?' do
    subject { get :index, params: { resource_name: 'teams' } }

    it { is_expected.to have_http_status(403) }
  end

  describe '.new' do
    subject { get :new, params: { resource_name: 'teams' } }

    it { is_expected.to have_http_status(403) }
  end

  describe 'create?' do
    subject { post :create, params: { resource_name: 'teams', resource: { name: 'Avocado team'  } } }

    it { is_expected.to have_http_status(403) }
  end

  describe 'show?' do
    subject { get :show, params: { resource_name: 'teams', id: dummy_team.id } }

    it { is_expected.to have_http_status(403) }
  end

  describe 'update?' do
    subject { put :update, params: { resource_name: 'teams', id: dummy_team.id, resource: { name: 'Avocado team' } } }

    it { is_expected.to have_http_status(403) }
  end

  describe 'edit?' do
    subject { get :edit, params: { resource_name: 'teams', id: dummy_team.id } }

    it { is_expected.to have_http_status(403) }
  end

  describe 'destroy?' do
    subject { delete :destroy, params: { resource_name: 'teams', id: dummy_team.id } }

    it { is_expected.to have_http_status(403) }
    it 'destroys the user' do
      subject

      expect(User.where(id: dummy_team.id).first).to be nil
    end
  end
end

RSpec.describe Avo::FiltersController, type: :controller do
  let(:user) { create :user }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe '.index' do
    subject { get :index, params: { resource_name: 'teams' } }

    it { is_expected.to have_http_status(403) }
  end
end

RSpec.describe Avo::SearchController, type: :controller do
  let(:user) { create :user }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe '.index' do
    subject { get :index, params: { resource_name: 'teams' } }

    it { is_expected.to have_http_status(200) }

    it 'does not return the Team resources' do
      expect(subject.parsed_body['resources'].pluck('label')).not_to include 'Team'
    end
  end

  describe '.resource' do
    subject { get :resource, params: { resource_name: 'teams' } }

    it { is_expected.to have_http_status(403) }
  end
end
