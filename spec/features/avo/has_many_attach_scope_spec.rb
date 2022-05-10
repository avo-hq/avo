require "rails_helper"

RSpec.feature "HasManyAttachScopes", type: :feature do
  let!(:user) { create :user }
  let!(:post) { create :post, user_id: user.id}
  let!(:post_2) { create :post}

  it "filters out the current selection" do
    visit "/admin/resources/users/#{user.id}/posts/new"

    expect(page).to have_select "fields[related_id]", options: ["Choose an option", post_2.name]
  end
end
