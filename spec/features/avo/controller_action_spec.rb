require "rails_helper"

RSpec.describe Avo::UsersController, type: :controller do
  let!(:user) { create :user}

  describe "@view instance variable" do
    it "assigns the @widget" do
      get :index

      assert assigns(:view).index?
    end

    it "assigns the @widget" do
      get :show, params: {id: user.id}

      assert assigns(:view).show?
    end

    it "assigns the @widget" do
      get :edit, params: {id: user.id}

      assert assigns(:view).edit?
    end

    it "assigns the @widget" do
      get :new

      assert assigns(:view).new?
    end

    it "assigns the @widget" do
      post :create, params: {user: {name: "Adrian"}}

      assert assigns(:view).create?
    end

    it "assigns the @widget" do
      put :update, params: {id: user.id, user: {name: "Adrian"}}

      assert assigns(:view).update?
    end

    it "assigns the @widget" do
      delete :destroy, params: {id: user.id}

      assert assigns(:view).destroy?
    end
  end
end
