require "rails_helper"

RSpec.describe Avo::UsersController, type: :controller do
  let!(:user) { create :user}

  describe "@view instance variable" do
    it "assigns the @widget" do
      get :index

      expect(assigns(:view)).to be :index
    end

    it "assigns the @widget" do
      get :show, params: {id: user.id}

      expect(assigns(:view)).to be :show
    end

    it "assigns the @widget" do
      get :edit, params: {id: user.id}

      expect(assigns(:view)).to be :edit
    end

    it "assigns the @widget" do
      get :new

      expect(assigns(:view)).to be :new
    end

    it "assigns the @widget" do
      post :create, params: {user: {name: "Adrian"}}

      expect(assigns(:view)).to be :create
    end

    it "assigns the @widget" do
      put :update, params: {id: user.id, user: {name: "Adrian"}}

      expect(assigns(:view)).to be :update
    end

    it "assigns the @widget" do
      delete :destroy, params: {id: user.id}

      expect(assigns(:view)).to be :destroy
    end
  end
end
