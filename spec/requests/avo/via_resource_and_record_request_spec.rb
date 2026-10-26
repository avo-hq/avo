require "rails_helper"

# A custom controller that overrides an action and calls `super` reads the parent it came through
# from `@via_resource` / `@via_record` instead of re-deriving it from the `via_*` params.
RSpec.describe "via_resource and via_record", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:post_record) { create :post, user: admin_user }

  before { login_as admin_user }

  def via_resource
    controller.instance_variable_get(:@via_resource)
  end

  def via_record
    controller.instance_variable_get(:@via_record)
  end

  describe "new" do
    it "resolves the parent from the model class" do
      get "/admin/resources/comments/new", params: {
        via_relation: "commentable",
        via_relation_class: "Post",
        via_record_id: post_record.to_param
      }

      expect(response).to have_http_status(:ok)
      expect(via_record).to eq post_record
      expect(via_resource).to be_an_instance_of(Avo::Resources::Post)
      expect(via_resource.record).to eq post_record
    end

    # Post and ZPost both map to the Post model, so only the resource class names the right one.
    it "prefers the resource class over the model class" do
      get "/admin/resources/comments/new", params: {
        via_relation: "commentable",
        via_relation_class: "Post",
        via_resource_class: "Avo::Resources::ZPost",
        via_record_id: post_record.to_param
      }

      expect(via_resource).to be_an_instance_of(Avo::Resources::ZPost)
      expect(via_record).to eq post_record
    end

    it "leaves both unset without a parent" do
      get "/admin/resources/comments/new"

      expect(response).to have_http_status(:ok)
      expect(via_resource).to be_nil
      expect(via_record).to be_nil
    end
  end

  describe "create" do
    it "exposes the parent the record was attached to" do
      post "/admin/resources/comments", params: {
        via_relation: "user",
        via_relation_class: "User",
        via_record_id: admin_user.to_param,
        comment: {body: "A comment"}
      }

      expect(Comment.last.user).to eq admin_user
      expect(via_record).to eq admin_user
      expect(via_resource).to be_an_instance_of(Avo::Resources::User)
    end
  end

  describe "show" do
    it "exposes the parent the record is viewed through" do
      get "/admin/resources/posts/#{post_record.to_param}", params: {
        via_resource_class: "Avo::Resources::User",
        via_record_id: admin_user.to_param
      }

      expect(via_record).to eq admin_user
      expect(via_resource).to be_an_instance_of(Avo::Resources::User)
    end
  end

  describe "edit" do
    it "exposes the parent the record is edited through" do
      get "/admin/resources/posts/#{post_record.to_param}/edit", params: {
        via_resource_class: "Avo::Resources::User",
        via_record_id: admin_user.to_param
      }

      expect(via_record).to eq admin_user
      expect(via_resource).to be_an_instance_of(Avo::Resources::User)
    end
  end
end
