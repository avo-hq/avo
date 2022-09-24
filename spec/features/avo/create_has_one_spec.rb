require "rails_helper"

RSpec.feature "CreateHasOne", type: :feature do
  let!(:user) { create :user }

  it "policy applyed" do
    visit "admin/resources/users/#{user.id}?active_tab_name=Fish&tab_turbo_frame=avo-tabgroup-2"

    expect(page).to have_text "Attach fish"
    expect(page).not_to have_text "Create fish"
  end

  it "creates new post" do
    visit "admin/resources/users/#{user.id}?active_tab_name=Main+post&tab_turbo_frame=avo-tabgroup-3"

    click_on "Create new main post"

    expect(page).to have_current_path("/admin/resources/posts/new?via_relation=user&via_relation_class=User&via_resource_id=#{user.id}")
    expect(page).to have_text user.name

    fill_in "post_name", with: "Main post name"
    click_on "Save"

    wait_for_loaded
    expect(page).to have_text "Post was successfully created."
    expect(page).to have_current_path("/admin/resources/users/#{user.id}")

    visit "/admin/resources/users/#{user.id}/post/#{user.post.id}?turbo_frame=has_one_field_show_post"

    expect(page).to have_text "Detach main post"
    expect(page).to have_text "Main post name"
  end

end
