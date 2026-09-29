require "rails_helper"

# Controllers that override an action and call `super` read the parent record from these.
RSpec.describe "Parent record of a nested view", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:user) { create :user }
  let!(:post_record) { create :post, user: }

  before do
    login_as admin_user
  end

  def expect_via_user
    expect(assigns(:via_record)).to eq user
    expect(assigns(:via_resource)).to be_a Avo::Resources::User
    expect(assigns(:via_resource).record).to eq user
  end

  it "assigns it on new" do
    get "/admin/resources/posts/new", params: {via_record_id: user.slug, via_relation: "user", via_relation_class: "User", via_resource_class: "Avo::Resources::User"}

    expect_via_user
  end

  it "assigns it on edit" do
    get "/admin/resources/posts/#{post_record.to_param}/edit", params: {via_record_id: user.slug, via_resource_class: "Avo::Resources::User"}

    expect_via_user
  end

  it "assigns it on show" do
    get "/admin/resources/posts/#{post_record.to_param}", params: {via_record_id: user.slug, via_resource_class: "Avo::Resources::User"}

    expect_via_user
  end

  it "assigns it on create" do
    post "/admin/resources/posts", params: {post: {name: "Via user"}, via_record_id: user.slug, via_relation: "user", via_relation_class: "User", via_resource_class: "Avo::Resources::User"}

    expect_via_user
    expect(Post.find_by(name: "Via user").user).to eq user
  end

  it "leaves it unset without a parent record" do
    get "/admin/resources/posts/new"

    expect(assigns(:via_record)).to be_nil
    expect(assigns(:via_resource)).to be_nil
  end
end
