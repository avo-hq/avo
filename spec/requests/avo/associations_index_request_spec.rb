# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations index", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:post_record) { create :post, user: admin_user }
  let!(:comment) { create :comment, commentable: post_record, body: "First comment" }

  before do
    login_as admin_user, scope: :user
  end

  it "loads the parent record once" do
    allow(Avo::Resources::Post).to receive(:find_record).and_call_original

    get "/admin/resources/posts/#{post_record.to_param}/comments?turbo_frame=has_many_field_show_comments"

    expect(response).to have_http_status :ok
    expect(response.body).to include "First comment"
    expect(Avo::Resources::Post).to have_received(:find_record).once
  end

  # Keyed on the service's record, not the query's model, so narrowing through the post's policy fails too.
  it "lists only the comments the listed resource's policy scope allows" do
    create :comment, commentable: post_record, body: "Hidden comment"

    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:apply_policy).and_wrap_original do |original, query|
      (original.receiver.record == Comment) ? query.where.not(body: "Hidden comment") : original.call(query)
    end

    get "/admin/resources/posts/#{post_record.to_param}/comments?turbo_frame=has_many_field_show_comments"

    expect(response.body).to include "First comment"
    expect(response.body).not_to include "Hidden comment"
  end
end
