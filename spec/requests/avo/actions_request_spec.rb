require "rails_helper"

RSpec.describe "Actions", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before do
    login_as admin_user
  end

  describe "cross-resource action execution" do
    # Security: an action registered on one resource must not be executable
    # through an unrelated resource endpoint. Previously, `action_class` walked
    # all `Avo::BaseAction.descendants` and matched on `params[:action_id]`
    # without validating that the action was registered for the current
    # resource, allowing privilege escalation (advisory: Illunight).
    it "does not execute an action that is not registered for the resource" do
      target = create(:user, roles: {admin: false})

      post "/admin/resources/posts/actions",
        params: {
          action_id: "Avo::Actions::ToggleAdmin",
          fields: {avo_resource_ids: target.id.to_s}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:redirect)
      expect(target.reload.roles["admin"]).to be_falsey
    end

    it "still serves actions that are registered for the resource" do
      get "/admin/resources/users/actions",
        params: {action_id: "Avo::Actions::ToggleAdmin"}

      expect(response).to have_http_status(:ok)
    end
  end

  describe "request object in handle" do
    it "gives the handle method access to the current request" do
      target = create(:user)
      path = "/admin/resources/users/actions"

      post path,
        params: {
          action_id: "Avo::Actions::ShowRequestPath",
          fields: {avo_resource_ids: target.id.to_s}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(flash[:success][:body]).to eq path
    end
  end

  # The resource must be one whose `find_record` actually raises on a missing
  # id. `Avo::Resources::User` uses FriendlyId, whose array branch is
  # `where(slug: ids)` and quietly returns fewer rows, so it can never
  # reproduce this race. `Avo::Resources::Fish` is plain ActiveRecord and goes
  # through `query.find(ids)`, which raises.
  describe "selected records deleted before execution" do
    it "runs the action for the records that still exist" do
      remaining = create(:fish)
      deleted_id = create(:fish).tap(&:destroy!).to_param

      post "/admin/resources/fish/actions",
        params: {
          action_id: "Avo::Actions::ReleaseFish",
          fields: {avo_resource_ids: [remaining.to_param, deleted_id].join(",")}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:ok)
      expect(flash[:success][:body]).to start_with "1 fish released"
    end

    it "runs the action with an empty query when every selected record is gone" do
      deleted_ids = 2.times.map { create(:fish).tap(&:destroy!).to_param }

      post "/admin/resources/fish/actions",
        params: {
          action_id: "Avo::Actions::ReleaseFish",
          fields: {avo_resource_ids: deleted_ids.join(",")}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(response).to have_http_status(:ok)
      expect(flash[:success][:body]).to start_with "0 fish released"
    end
  end
end
