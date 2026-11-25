# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Referrer param", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:post_record) { create :post, name: "Hello" }
  let(:post_path) { "/admin/resources/posts/#{post_record.to_param}" }

  before do
    login_as admin_user, scope: :user
  end

  it "sends an update back to the record when the referrer points outside the app" do
    ["https://attacker.example/sign_in", "//attacker.example", "/\\attacker.example", "javascript:alert(1)"].each do |referrer|
      patch post_path, params: {post: {name: "Hello"}, referrer: referrer}

      expect(response).to redirect_to post_path
    end
  end

  it "follows a referrer that stays inside the app" do
    ["/admin/resources/users?page=2", "http://www.example.com/admin/resources/users?page=2"].each do |referrer|
      patch post_path, params: {post: {name: "Hello"}, referrer: referrer}

      expect(response).to redirect_to referrer
    end
  end
end
