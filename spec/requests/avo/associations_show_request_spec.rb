# frozen_string_literal: true

require "rails_helper"

# GHSA-x65r-p6hf-94hv: the association show route renders the related record,
# so it must ask the related resource's policy, the way the resource show page does.
RSpec.describe "Associations show", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:post_record) { create :post, user: admin_user, name: "Secret post" }

  let(:has_many_path) { "/admin/resources/users/#{admin_user.to_param}/posts/#{post_record.to_param}" }

  before { login_as admin_user, scope: :user }

  # Denies only the related post, so a fix that checks the parent instead still fails.
  def deny_post_show
    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:authorize_action).and_wrap_original do |original, action, *args, **kwargs|
      raise Avo::NotAuthorizedError if action == :show && original.receiver.record.is_a?(Post)

      original.call(action, *args, **kwargs)
    end
  end

  it "renders the related record when its policy allows it" do
    get has_many_path

    expect(response).to have_http_status :ok
    expect(response.body).to include "Secret post"
  end

  it "refuses a has_many related record its show policy denies" do
    deny_post_show

    get has_many_path

    expect(response).to have_http_status :redirect
  end

  it "refuses a has_one related record its show policy denies" do
    deny_post_show

    get "/admin/resources/users/#{admin_user.to_param}/post/#{post_record.to_param}"

    expect(response).to have_http_status :redirect
  end

  # Comment, not Post: Post's find_record_method uses find_by_slug, which returns nil instead of raising.
  it "does not find a related record outside the related policy scope" do
    comment = create :comment, user: admin_user

    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:apply_policy).and_wrap_original do |original, query|
      model = query.is_a?(Class) ? query : query.klass
      (model <= Comment) ? query.none : original.call(query)
    end

    expect { get "/admin/resources/users/#{admin_user.to_param}/comments/#{comment.to_param}" }.to raise_error ActiveRecord::RecordNotFound
  end
end
