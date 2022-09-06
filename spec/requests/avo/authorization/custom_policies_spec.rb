require "rails_helper"

class PhotoCommentPolicy < ApplicationPolicy
  # Overriding the scope to only show user's comments. We'll be checking in the test below that it doesn't show up
  class Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

  def index?
    false
  end
end

RSpec.describe "CustomPolicies" do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:comment) { create :comment, body: "I should NOT show up" }
  let!(:admin_comment) { create :comment, body: "I should show up" }

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

  describe "using custom scopes", type: :feature do
    it "should not show any comments" do
      # Allow index just for this test
      # FIXME: Somehow, the called resource is STILL not the good one, Comment instead of PhotoComment
      # Need to investigate
      allow_any_instance_of(PhotoCommentPolicy).to receive(:index?).and_return true
      visit "/admin/resources/photo_comments"
      expect(current_path).to eql "/admin/resources/photo_comments"
      expect(page).to have_text "I should show up"
      expect(page).not_to have_text "I should NOT show up"
    end
  end
end
