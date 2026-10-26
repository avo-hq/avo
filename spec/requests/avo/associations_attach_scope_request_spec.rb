require "rails_helper"

RSpec.describe "Attaching through the field's attach_scope", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:user) { create :user }
  let!(:main_post) { create :post, user: user }
  let!(:hidden_post) { create :post }

  # Returns the outcome instead of asserting one: a refused record must look like a missing one.
  def attach(association, param)
    login_as admin_user
    post "/admin/resources/users/#{user.to_param}/#{association}", params: {fields: {related_id: param}}, as: :turbo_stream
    response.status
  rescue ActiveRecord::RecordNotFound => error
    error.class
  end

  it "refuses a record outside a narrowing attach_scope like a missing one" do
    hidden_id = hidden_post.id
    allow_any_instance_of(Avo::Fields::HasOneField).to receive(:attach_scope).and_return(-> { query.where.not(id: hidden_id) })

    expect(attach(:post, hidden_post.to_param)).to eq attach(:post, "missing-post")
    expect(user.reload.post).to eq main_post
  end

  it "accepts a record a widening attach_scope lists outside the policy scope" do
    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:apply_policy).and_wrap_original do |original, query|
      model = query.is_a?(Class) ? query : query.klass
      (model <= Post) ? query.where.not(id: hidden_post.id) : original.call(query)
    end
    allow_any_instance_of(Avo::Fields::HasManyField).to receive(:attach_scope).and_return(-> { ::Post.all })

    attach(:posts, hidden_post.to_param)

    expect(user.reload.posts).to include hidden_post
  end
end
