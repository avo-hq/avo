require 'rails_helper'

class UserPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def show?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def new?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end
end

RSpec.describe Avo::ResourcesController, type: :controller do
  let(:user) { create :user }
  let(:admin_user) { create :user, roles: { 'admin': true } }
  let(:dummy_user) { create :user }

  before do
    sign_in user
  end

  describe 'index?' do
    subject { get :index, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'fields?' do
    subject { get :fields, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'filters?' do
    subject { get :filters, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'create?' do
    subject { post :create, params: { resource_name: 'users', resource: { first_name: 'Avo', last_name: 'Cado', email: 'avo@cado.com', password: 'secret_avocado' } } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'show?' do
    subject { get :show, params: { resource_name: 'users', id: dummy_user.id } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'update?' do
    subject { put :update, params: { resource_name: 'users', id: dummy_user.id, resource: { first_name: 'Avo', last_name: 'Cado', email: 'avo@cado.com', password: 'secret_avocado' } } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'edit?' do
    subject { get :edit, params: { resource_name: 'users', id: dummy_user.id } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe 'destroy?' do
    subject { delete :destroy, params: { resource_name: 'users', id: dummy_user.id } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
      it 'does not destroy the user' do
        subject

        expect(dummy_user.reload).not_to be nil
      end
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
      it 'destroys the user' do
        subject

        expect(User.where(id: dummy_user.id).first).to be nil
      end
    end
  end

  describe '.search' do
    subject { get :search, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(200) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe '.resource_search' do
    subject { get :search, params: { resource_name: 'users' } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(200) }
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end
end
