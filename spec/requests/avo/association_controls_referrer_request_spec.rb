# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Association row controls referrer", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let!(:post_record) { create :post, user: admin_user, name: "C++ & Rust" }

  before do
    login_as admin_user, scope: :user
  end

  # The detach and destroy links redirect to this referrer, so the panel must come back with the same search.
  it "keeps the search query intact in the detach and destroy links" do
    get "/admin/resources/users/#{admin_user.slug}/posts",
      params: {turbo_frame: "has_many_field_posts", view_type: "table", q: "C++ & Rust"},
      headers: {"Turbo-Frame" => "has_many_field_posts"}

    hrefs = Nokogiri::HTML(response.body).css("a[href*='referrer=']").map { |link| link["href"] }
    expect(hrefs).not_to be_empty

    hrefs.each do |href|
      referrer = Rack::Utils.parse_nested_query(URI.parse(href).query)["referrer"]

      expect(Rack::Utils.parse_nested_query(URI.parse(referrer).query)["q"]).to eq "C++ & Rust"
    end
  end
end
