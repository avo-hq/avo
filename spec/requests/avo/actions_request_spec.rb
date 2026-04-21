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
end
