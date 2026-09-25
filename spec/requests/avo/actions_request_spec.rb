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

  describe "modal_width" do
    around do |example|
      original = Avo::Actions::ToggleAdmin.modal_width
      example.run
      Avo::Actions::ToggleAdmin.modal_width = original
    end

    it "opens the modal at the component's default width" do
      get "/admin/resources/users/actions", params: {action_id: "Avo::Actions::ToggleAdmin"}

      expect(response.body).to include('class="modal modal--width-xl')
    end

    it "opens the modal at the width the action asks for" do
      Avo::Actions::ToggleAdmin.modal_width = :"4xl"

      get "/admin/resources/users/actions", params: {action_id: "Avo::Actions::ToggleAdmin"}

      expect(response.body).to include('class="modal modal--width-4xl')
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

  describe "polymorphic belongs_to field" do
    it "passes both the type and the id to handle" do
      review = create(:review)

      post "/admin/resources/reviews/actions",
        params: {
          action_id: "Avo::Actions::Test::ShowPolymorphicFields",
          fields: {
            avo_resource_ids: review.id.to_s,
            reviewable_type: "Post",
            reviewable_id: "12345"
          }
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(flash[:success][:body]).to eq "Post 12345"
    end
  end

  # avo-hq/avo#2190: the controller used to force `view` to :new on both the
  # action and the resource, so `view` in an action's blocks never said where
  # the action was started from, and fields hidden on the new view (badge)
  # never reached the modal.
  describe "the view the action was started from" do
    let(:action_id) { "Avo::Actions::Test::ShowView" }

    it "opens the modal with the index view" do
      get "/admin/resources/reviews/actions", params: {action_id: action_id, resource_view: "index"}

      expect(response.body).to include "view=index resource.view=index"
    end

    it "opens the modal with the show view" do
      review = create(:review)

      get "/admin/resources/reviews/#{review.id}/actions", params: {action_id: action_id, resource_view: "show"}

      expect(response.body).to include "view=show resource.view=show"
    end

    it "runs the action with the index view" do
      post "/admin/resources/reviews/actions",
        params: {
          action_id: action_id,
          resource_view: "index",
          fields: {avo_resource_ids: "", probe_hidden: "hidden-default"}
        },
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(flash[:success][:body]).to eq "view=index resource.view=index probe_hidden=hidden-default"
    end

    it "renders every declared field, display-only ones included, with defaults prefilled" do
      get "/admin/resources/reviews/actions", params: {action_id: action_id, resource_view: "index"}

      expect(response.body).to include "Probe badge"
      expect(response.body).to match(/<input[^>]*name="fields\[probe_hidden\]"[^>]*>/)
      expect(response.body).to include 'value="hidden-default"'
      expect(response.body).to include 'value="text-default"'
    end

    it "keeps the edit view, and every field, when started from a record's edit page" do
      review = create(:review)

      get "/admin/resources/reviews/#{review.id}/actions", params: {action_id: action_id, resource_view: "edit"}

      expect(response.body).to include "view=edit resource.view=edit"
      # A badge is hidden on a resource's edit form; an action's field list is not a resource form.
      expect(response.body).to include "Probe badge"
    end

    it "keeps the index view for a row action, which posts to the record path" do
      review = create(:review)

      get "/admin/resources/reviews/#{review.id}/actions", params: {action_id: action_id, resource_view: "index"}

      expect(response.body).to include "view=index resource.view=index"
    end

    it "derives the view from the route when a hand-built link carries none" do
      get "/admin/resources/reviews/actions", params: {action_id: action_id}

      expect(response.body).to include "view=index resource.view=index"

      review = create(:review)

      get "/admin/resources/reviews/#{review.id}/actions", params: {action_id: action_id}

      expect(response.body).to include "view=show resource.view=show"
    end

    it "does not trust a view the route cannot back up" do
      # Without a record in the URL there is no show page to have come from, so a
      # claimed show origin cannot satisfy an `authorize` block on `view.show?`.
      get "/admin/resources/reviews/actions", params: {action_id: action_id, resource_view: "show"}

      expect(response.body).to include "view=index resource.view=index"

      post "/admin/resources/reviews/actions",
        params: {action_id: action_id, resource_view: "show", fields: {avo_resource_ids: "", probe_hidden: "x"}},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}

      expect(flash[:success][:body]).to start_with "view=index resource.view=index"

      # The modal never runs on a form view, whatever the request says.
      review = create(:review)

      get "/admin/resources/reviews/#{review.id}/actions", params: {action_id: action_id, resource_view: "new"}

      expect(response.body).to include "view=show resource.view=show"
    end

    it "focuses the first input rather than a display-only field" do
      get "/admin/resources/reviews/actions", params: {action_id: action_id, resource_view: "index"}

      expect(response.body).to match(/<input(?=[^>]*name="fields\[probe_text\]")(?=[^>]*autofocus)[^>]*>/)
    end
  end
end
