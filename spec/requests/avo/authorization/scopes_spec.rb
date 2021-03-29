require "rails_helper"

RSpec.describe Avo::UsersController, type: :controller do
  let(:regular_user) { create :user }
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:active_user) { create :user, first_name: "active user", active: true }
  let!(:inactive_user) { create :user, first_name: "inactive user", active: false }
  let(:dummy_user) { create :user }
  let(:project) { create :project }

  before do
    project.users << active_user
    project.users << inactive_user
  end

  before :each do
    sign_in user
  end

  before :all do
    class UserPolicy < ApplicationPolicy
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
  end

  after :all do
    class UserPolicy < ApplicationPolicy
      def index?
        false
      end

      def show?
        false
      end

      def create?
        false
      end

      def new?
        false
      end

      def update?
        false
      end

      def edit?
        false
      end

      def destroy?
        false
      end

      class Scope < ApplicationPolicy::Scope
        def resolve
          scope.all
        end
      end
    end
  end

  describe ".index" do
    subject { get :index }

    context "when user is not admin" do
      let(:user) { regular_user }

      it "returns the scoped results" do
        subject

        resource_ids = assigns(:models).collect { |i| i.id }
        expect(resource_ids).to include active_user.id
        expect(resource_ids).not_to include inactive_user.id
      end
    end

    context "when user is admin" do
      let(:user) { admin_user }

      it "returns the scoped results" do
        subject

        resource_ids = assigns(:models).collect { |i| i.id }
        expect(resource_ids).to include active_user.id
        expect(resource_ids).to include inactive_user.id
      end
    end

    describe "with via_resource_name" do
      subject { get :index, params: {via_resource_name: "projects", via_resource_id: project.id, via_relationship: "users"} }

      context "when user is not admin" do
        let(:user) { regular_user }

        it "returns the scoped results" do
          subject

          resource_ids = assigns(:models).collect { |i| i.id }
          expect(resource_ids).to include active_user.id
          expect(resource_ids).not_to include inactive_user.id
        end
      end

      context "when user is admin" do
        let(:user) { admin_user }

        it "returns the scoped results" do
          subject

          resource_ids = assigns(:models).collect { |i| i.id }
          expect(resource_ids).to include active_user.id
          expect(resource_ids).to include inactive_user.id
        end
      end
    end
  end
end

# RSpec.describe Avo::SearchController, type: :controller do
#   let(:regular_user) { create :user }
#   let(:admin_user) { create :user, roles: { admin: true } }
#   let!(:active_user) { create :user, first_name: 'active user', active: true }
#   let!(:inactive_user) { create :user, first_name: 'inactive user', active: false }
#   let(:dummy_user) { create :user }
#   let(:project) { create :project }

#   before do
#     project.users << active_user
#     project.users << inactive_user
#   end

#   before :each do
#     sign_in user
#   end

#   before :all do
#     class UserPolicy < ApplicationPolicy
#       def index?
#         true
#       end

#       def show?
#         true
#       end

#       def create?
#         true
#       end

#       def new?
#         true
#       end

#       def update?
#         true
#       end

#       def edit?
#         true
#       end

#       def destroy?
#         true
#       end

#       class Scope < ApplicationPolicy::Scope
#         def resolve
#           if user.is_admin?
#             scope.all
#           else
#             scope.where(active: true)
#           end
#         end
#       end
#     end
#   end

#   after :all do
#     class UserPolicy < ApplicationPolicy
#       def index?
#         false
#       end

#       def show?
#         false
#       end

#       def create?
#         false
#       end

#       def new?
#         false
#       end

#       def update?
#         false
#       end

#       def edit?
#         false
#       end

#       def destroy?
#         false
#       end

#       class Scope < ApplicationPolicy::Scope
#         def resolve
#           scope.all
#         end
#       end
#     end
#   end

#   describe '.index' do
#     subject { get :index, params: { resource_name: 'users' } }

#     context 'when user is not admin' do
#       let(:user) { regular_user }

#       it 'returns the scoped results' do
#         subject

#         resource_ids = assigns(:models).collect { |i| i.id }
#         expect(resource_ids).to include active_user.id
#         expect(resource_ids).not_to include inactive_user.id
#       end
#     end

#     context 'when user is admin' do
#       let(:user) { admin_user }

#       it 'returns the scoped results' do
#         subject

#         resource_ids = assigns(:models).collect { |i| i.id }
#         expect(resource_ids).to include active_user.id
#         expect(resource_ids).to include inactive_user.id
#       end
#     end

#     describe 'with via_resource_name' do
#       subject { get :index, params: { resource_name: 'users', via_resource_name: 'projects', via_resource_id: project.id, via_relationship: 'users' } }

#       context 'when user is not admin' do
#         let(:user) { regular_user }

#         it 'returns the scoped results' do
#           subject

#           resource_ids = assigns(:models).collect { |i| i.id }
#           expect(resource_ids).to include active_user.id
#           expect(resource_ids).not_to include inactive_user.id
#         end
#       end

#       context 'when user is admin' do
#         let(:user) { admin_user }

#         it 'returns the scoped results' do
#           subject

#           resource_ids = assigns(:models).collect { |i| i.id }
#           expect(resource_ids).to include active_user.id
#           expect(resource_ids).to include inactive_user.id
#         end
#       end
#     end
#   end
# end

# # RSpec.describe Avo::SearchController, type: :controller do
# #   let(:regular_user) { create :user }
# #   let(:admin_user) { create :user, roles: { admin: true } }
# #   let!(:active_user) { create :user, first_name: 'active user', active: true }
# #   let!(:inactive_user) { create :user, first_name: 'inactive user', active: false }

# #   before :each do
# #     stub_pro_license_request
# #   end

# #   before do
# #     sign_in user
# #   end

# #   before :all do
# #     class UserPolicy < ApplicationPolicy
# #       def index?
# #         true
# #       end

# #       class Scope < ApplicationPolicy::Scope
# #         def resolve
# #           if user.is_admin?
# #             scope.all
# #           else
# #             scope.where(active: true)
# #           end
# #         end
# #       end
# #     end
# #   end

# #   after :all do
# #     class UserPolicy < ApplicationPolicy
# #       def index?
# #         false
# #       end

# #       class Scope < ApplicationPolicy::Scope
# #         def resolve
# #           scope.all
# #         end
# #       end
# #     end
# #   end

# #   describe '.resource' do
# #     subject { get :resource, params: { resource_name: 'users', q: 'active' } }

# #     context 'when user is not admin' do
# #       let(:user) { regular_user }

# #       it 'returns scoped results' do
# #         subject

# #         resource_ids = assigns(:models).collect { |i| i.id }
# #         expect(resource_ids).to include active_user.id
# #         expect(resource_ids).not_to include inactive_user.id
# #       end
# #     end

# #     context 'when user is admin' do
# #       let(:user) { admin_user }

# #       it 'returns scoped results' do
# #         subject

# #         resource_ids = assigns(:models).collect { |i| i.id }
# #         expect(resource_ids).to include active_user.id
# #         expect(resource_ids).to include inactive_user.id
# #       end
# #     end
# #   end

# #   describe '.index' do
# #     subject { get :index, params: { q: 'active' } }

# #     context 'when user is not admin' do
# #       let(:user) { regular_user }

# #       it 'returns scoped results' do
# #         subject

# #         resource_ids = assigns(:models).find { |group| group['label'] == 'User' }['resources'].collect { |i| i.id }
# #         expect(resource_ids).to include active_user.id
# #         expect(resource_ids).not_to include inactive_user.id
# #       end
# #     end

# #     context 'when user is admin' do
# #       let(:user) { admin_user }

# #       it 'returns scoped results' do
# #         subject
# #         resource_ids = assigns(:models).find { |group| group['label'] == 'User' }['resources'].collect { |i| i.id }

# #         expect(resource_ids).to include active_user.id
# #         expect(resource_ids).to include inactive_user.id
# #       end
# #     end
# #   end
# # end
