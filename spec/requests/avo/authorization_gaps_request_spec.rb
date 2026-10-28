# frozen_string_literal: true

require "rails_helper"

# AVO-1897: routes that reached a record past the policy the resource's own page asks.
RSpec.describe "Authorization gaps", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:other_user) { create :user }

  before { login_as admin_user, scope: :user }

  # Stands in for a policy client: raises Avo::NotAuthorizedError when the block returns true for (action, service).
  def deny_when(&denied)
    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:authorize_action).and_wrap_original do |original, action, *args, **kwargs|
      raise Avo::NotAuthorizedError if denied.call(action.to_s.delete_suffix("?").to_sym, original.receiver)

      original.call(action, *args, **kwargs)
    end
  end

  describe "update" do
    let!(:post_record) { create :post, user: other_user, name: "Theirs" }

    # The owner-only policy many hosts write: `record.user == user`.
    before { deny_when { |action, service| action.in?([:edit, :update]) && service.record.try(:user_id) != service.user.id } }

    it "refuses an update that makes the record pass its policy by changing it" do
      put "/admin/resources/posts/#{post_record.to_param}", params: {post: {user_id: admin_user.id, name: "Mine now"}}

      expect(response).to have_http_status :redirect
      expect(post_record.reload).to have_attributes(user_id: other_user.id, name: "Theirs")
    end

    it "refuses a reactive edit form the same way" do
      put "/admin/resources/posts/#{post_record.to_param}/edit", params: {react_on: "user", post: {user_id: admin_user.id}}

      expect(response).to have_http_status :redirect
    end

    it "still checks the submitted values" do
      own_post = create :post, user: admin_user, name: "Mine"
      deny_when { |action, service| action == :update && service.record.try(:name) == "Forbidden" }

      put "/admin/resources/posts/#{own_post.to_param}", params: {post: {name: "Forbidden"}}

      expect(own_post.reload.name).to eq "Mine"
    end

    it "updates a record its policy allows" do
      own_post = create :post, user: admin_user, name: "Mine"

      put "/admin/resources/posts/#{own_post.to_param}", params: {post: {name: "Renamed"}}

      expect(own_post.reload.name).to eq "Renamed"
    end
  end

  describe "distribution chart" do
    it "refuses a chart of a resource whose index the policy denies" do
      deny_when { |action, _service| action == :index }

      get "/admin/posts/status/distribution_chart"

      expect(response).to have_http_status :redirect
    end
  end

  describe "has_one detach" do
    it "does not detach a record other than the one in the URL" do
      users_post = create :post, user: admin_user
      someone_elses_post = create :post, user: other_user

      expect {
        delete "/admin/resources/users/#{admin_user.to_param}/post/#{someone_elses_post.to_param}"
      }.to raise_error ActiveRecord::RecordNotFound

      expect(admin_user.reload.post).to eq users_post
    end
  end

  # The index and the search endpoint list a parent's association named in params, as its panel does.
  describe "listing through a parent's association" do
    let!(:post_record) { create :post, user: admin_user, name: "Secret post" }

    before do
      allow(Avo.configuration).to receive(:authorization_enabled?).and_return(true)
      allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:has_method?).and_return(true)
    end

    {
      index: ->(resource, user) { "/admin/resources/#{resource}?via_resource_class=Avo::Resources::User&via_record_id=#{user.to_param}&related_name=posts" },
      search: ->(resource, user) { "/admin/avo_api/#{resource}/search?q=Secret&via_association=has_many&via_association_id=posts&via_reflection_class=User&via_reflection_id=#{user.to_param}&via_reflection_view=show" }
    }.each do |endpoint, path|
      describe endpoint.to_s do
        it "lists the parent's association" do
          get path.call("posts", admin_user)

          expect(response).to have_http_status :ok
          expect(response.body).to include post_record.to_param
        end

        # The user's posts through the Spouse resource, so filtered by Spouse's policy scope instead of Post's.
        it "refuses a resource other than the one the association lists" do
          expect { get path.call("spouses", admin_user) }.to raise_error ActiveRecord::RecordNotFound
        end

        # Denies only the parent user, so a fix that asks the listed post instead still fails.
        it "refuses when the parent's view_<association>? denies it" do
          deny_when { |action, service| action == :view_posts && service.record == admin_user }

          get path.call("posts", admin_user)

          expect(response).to have_http_status :redirect
        end
      end
    end
  end
end
