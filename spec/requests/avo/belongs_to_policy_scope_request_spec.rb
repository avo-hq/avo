require "rails_helper"

RSpec.describe "belongs_to target outside the policy scope", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:hidden_user) { create :user }
  let!(:post_record) { create :post, user: admin_user }

  before do
    allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:apply_policy).and_wrap_original do |original, query|
      model = query.is_a?(Class) ? query : query.klass
      (model <= User) ? query.where.not(id: hidden_user.id) : original.call(query)
    end
  end

  # Returns the outcome instead of asserting one: what matters is that the two can't be told apart.
  def assign_user(param)
    login_as admin_user
    patch "/admin/resources/posts/#{post_record.to_param}", params: {post: {user_id: param}}
    response.status
  rescue ActiveRecord::RecordNotFound => error
    error.class
  end

  it "refuses it like a missing one" do
    expect(assign_user(hidden_user.to_param)).to eq assign_user("missing-user")
    expect(post_record.reload.user).to eq admin_user
  end
end
