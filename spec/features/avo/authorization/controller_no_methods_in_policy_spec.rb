require 'rails_helper'

class PostPolicy < ApplicationPolicy
end

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:user) { create :user }
  let(:dummy_post) { create :post }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe 'index?' do
    subject { get :index, params: { resource_name: 'posts' } }

    it { is_expected.to have_http_status(200) }
  end

  describe '.new' do
    subject { get :new, params: { resource_name: 'posts' } }

    it { is_expected.to have_http_status(200) }
  end

  describe 'create?' do
    subject { post :create, params: { resource_name: 'posts', resource: { name: 'All bout avocados'  } } }

    it { is_expected.to have_http_status(200) }
  end

  describe 'show?' do
    subject { get :show, params: { resource_name: 'posts', id: dummy_post.id } }

    it { is_expected.to have_http_status(200) }
  end

  describe 'update?' do
    subject { put :update, params: { resource_name: 'posts', id: dummy_post.id, resource: { name: 'All bout avocados' } } }

    it { is_expected.to have_http_status(200) }
  end

  describe 'edit?' do
    subject { get :edit, params: { resource_name: 'posts', id: dummy_post.id } }

    it { is_expected.to have_http_status(200) }
  end

  describe 'destroy?' do
    subject { delete :destroy, params: { resource_name: 'posts', id: dummy_post.id } }

    it { is_expected.to have_http_status(200) }
    it 'destroys the user' do
      subject

      expect(User.where(id: dummy_post.id).first).to be nil
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
    subject { get :index, params: { resource_name: 'posts' } }

    it { is_expected.to have_http_status(200) }
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

  describe '.search' do
    subject { get :index, params: { resource_name: 'posts' } }

    it { is_expected.to have_http_status(200) }
  end

  describe '.resource_search' do
    subject { get :resource, params: { resource_name: 'posts' } }

    it { is_expected.to have_http_status(200) }
  end
end
