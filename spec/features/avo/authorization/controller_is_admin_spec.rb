require 'rails_helper'

class ProjectPolicy < ApplicationPolicy
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
  let(:project) { create :project }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe 'index?' do
    subject { get :index, params: { resource_name: 'projects' } }

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
    subject { get :index, params: { resource_name: 'projects' } }

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
    subject { post :create, params: { resource_name: 'projects', resource: { name: 'Avocado peeling', users_required: 10 } } }

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
    subject { get :show, params: { resource_name: 'projects', id: project.id } }

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
    subject { put :update, params: { resource_name: 'projects', id: project.id, resource: { name: 'Avocado peeling', users_required: 10 } } }

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
    subject { get :edit, params: { resource_name: 'projects', id: project.id } }

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
    subject { delete :destroy, params: { resource_name: 'projects', id: project.id } }

    context 'when user is not admin' do
      it { is_expected.to have_http_status(403) }
      it 'does not destroy the user' do
        subject

        expect(project.reload).not_to be nil
      end
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
      it 'destroys the user' do
        subject

        expect(User.where(id: project.id).first).to be nil
      end
    end
  end
end

RSpec.describe Avo::FiltersController, type: :controller do
  let(:user) { create :user }
  let(:admin_user) { create :user, roles: { 'admin': true } }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  describe 'index' do
    subject { get :index, params: { resource_name: 'projects' } }

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
end

RSpec.describe Avo::SearchController, type: :controller do
  let(:user) { create :user }
  let(:admin_user) { create :user, roles: { 'admin': true } }

  before :each do
    stub_pro_license_request
  end

  before do
    sign_in user
  end

  after :all do
    # What an ugly solution!
    # We gotta reset the policy for the next specs
    class ProjectPolicy < ApplicationPolicy
      def index?
        true
      end

      def show?
        true
      end

      def create?
        true
      end

      def new?
        true
      end

      def update?
        true
      end

      def edit?
        true
      end

      def destroy?
        true
      end
    end
  end

  describe '.index' do
    subject { get :index, params: { resource_name: 'projects' } }

    context 'when user is not admin' do
      # The request will not be a 403, but the resource should be filtered out from search results.
      it { is_expected.to have_http_status(200) }

      it 'does not return the Project resources' do
        expect(subject.parsed_body['resources'].pluck('label')).not_to include 'Project'
      end
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
      end

      it { is_expected.to have_http_status(200) }
    end
  end

  describe '.resource' do
    subject { get :resource, params: { resource_name: 'projects' } }

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
end
