require "rails_helper"

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

RSpec.describe "ProjectsController is_admin? policy", type: :request do
  let(:user) { create :user }
  let(:admin_user) { create :user, roles: {'admin': true} }
  let(:project) { create :project }

  before do
    login_as user
  end

  describe "index?" do
    subject { get "/admin/resources/projects" }

    context "when user is not admin" do
      it "will not find the avo route" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to be 200 }
    end
  end

  describe "create?" do
    subject { post "/admin/resources/projects", params: {project: {name: "Avocado peeling", users_required: 10}} }

    context "when user is not admin" do
      it "fails" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to redirect_to("/admin/resources/projects/#{Project.first.id}") }
    end
  end

  describe "show?" do
    subject { get "/admin/resources/projects/#{project.id}" }

    context "when user is not admin" do
      it "fails" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to be 200 }
    end
  end

  describe "update?" do
    subject { put "/admin/resources/projects/#{project.id}", params: {project: {name: "Avocado peeling", users_required: 10}} }

    context "when user is not admin" do
      it "fails" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to redirect_to("/admin/resources/projects/#{project.id}") }
    end
  end

  describe "edit?" do
    subject { get "/admin/resources/projects/#{project.id}" }

    context "when user is not admin" do
      it "fails" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to be 200 }
    end
  end

  describe "destroy?" do
    subject { delete "/admin/resources/projects/#{project.id}" }

    context "when user is not admin" do
      it "fails" do
        expect { subject }.to raise_error ActionController::RoutingError
      end
    end

    context "when user is admin" do
      before do
        login_as admin_user
      end

      it { is_expected.to redirect_to("/admin/resources/projects") }
      it "destroys the user" do
        subject

        expect(Project.where(id: project.id).first).to be nil
      end
    end
  end
end
