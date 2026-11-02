# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Association refresh_on_destroy", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:fish) { create :fish }
  let!(:review) { create :review, reviewable: fish }
  let!(:post_record) { create :post, user: admin_user }

  before do
    login_as admin_user, scope: :user
  end

  def destroy_href(path, frame)
    get path, params: {turbo_frame: frame}, headers: {"Turbo-Frame" => frame}

    Nokogiri::HTML(response.body).at_css("a[data-control='destroy']")["href"]
  end

  it "reloads the whole page after destroying a record from a field with refresh_on_destroy" do
    href = destroy_href("/admin/resources/fish/#{fish.id}/reviews", "has_many_field_show_reviews")

    expect { delete href, as: :turbo_stream }.to change(Review, :count).by(-1)
    expect(response.body).to include 'action="turbo_reload"'
    expect(response.body).not_to include 'action="turbo_frame_reload"'
  end

  it "reloads only the association frame by default" do
    href = destroy_href("/admin/resources/users/#{admin_user.slug}/posts", "has_many_field_posts")

    expect { delete href, as: :turbo_stream }.to change(Post, :count).by(-1)
    expect(response.body).to include 'action="turbo_frame_reload"'
    expect(response.body).not_to include 'action="turbo_reload"'
  end
end
