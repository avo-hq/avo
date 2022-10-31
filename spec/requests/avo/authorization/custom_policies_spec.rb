require "rails_helper"

RSpec.describe "CustomPolicies" do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:comment) { create :comment, body: "I should NOT show up" }
  let!(:admin_comment) { create :comment, body: "I should show up", user: admin_user }

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
      get "/admin/resources/photo_comments/#{Comment.last.id}"
      expect(response).to have_http_status :success
    end
  end

  describe "using custom scopes", type: :feature do
    it "should only show current user comments" do
      # Allow index just for this test
      allow_any_instance_of(PhotoCommentPolicy).to receive(:index?).and_return true
      # Changing the scope to only allow current user comments for this test
      PhotoCommentPolicy::Scope.define_method(:resolve) do
        scope.where(user_id: user.id)
      end
      login_as admin_user
      visit "/admin/resources/photo_comments"
      expect(current_path).to eql "/admin/resources/photo_comments"
      expect(page).to have_text "I should show up"
      expect(page).not_to have_text "I should NOT show up"
    end
  end
end
