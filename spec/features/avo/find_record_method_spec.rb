require "rails_helper"

RSpec.feature "FindRecordMethod", type: :feature do
  let(:post) { create :post }
  let(:sibling) { create :sibling }

  it "finds the proper record by slug" do
    visit "/admin/resources/posts/#{post.slug}"

    expect(page).to have_text post.name
  end

  it "finds the proper record by id" do
    visit "/admin/resources/posts/#{post.id}"

    expect(page).to have_text post.name
  end

  it "finds the proper record by name" do
    visit "/admin/resources/siblings/#{ERB::Util.url_encode(sibling.name)}"

    expect(page).to have_text sibling.name
  end
end
