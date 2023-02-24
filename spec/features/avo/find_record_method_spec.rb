require "rails_helper"

RSpec.feature "FindRecordMethod", type: :feature do
  let(:post) { create :post }

  it "finds the proper record by slug" do
    visit "/admin/resources/posts/#{post.slug}"

    expect(page).to have_text post.name
  end

  it "finds the proper record by id" do
    visit "/admin/resources/posts/#{post.id}"

    expect(page).to have_text post.name
  end
end
