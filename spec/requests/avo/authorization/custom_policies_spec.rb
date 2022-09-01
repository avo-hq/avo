require "rails_helper"

class PhotoCommentPolicy < ApplicationPolicy
  def index?
    false
  end
end

RSpec.describe "CustomPolicies" do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:comment) { create :comment }

  describe "PhotoCommentResource" do
    it "uses its own policy" do
      expect(PhotoCommentResource.authorization_policy).to eq(PhotoCommentPolicy)
    end
  end

  describe "using custom policy instead of default model policy", type: :request do
    before do
      login_as admin_user
    end

    it "should not allow access to PhotoComments#index" do
      get "/admin/resources/photo_comments"
      expect(response).to redirect_to("/admin/")
    end

    it "should still allow access to Comments#index" do
      get "/admin/resources/comments"
      expect(response).to have_http_status :success
    end

    it "should allow edition of a PhotoComment" do
      get "/admin/resources/photo_comments/#{comment.id}"
      expect(response).to have_http_status :success
    end
  end
end
