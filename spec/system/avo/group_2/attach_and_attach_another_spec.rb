# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attach and attach another", type: :system do
  let!(:project) { create(:project) }
  let!(:comments) { create_list(:comment, 2) }

  it "attaches 2 comments without closing the modal" do
    visit avo.resources_project_path(project)

    scroll_to find('turbo-frame[id="has_many_field_show_comments"]')

    # The users frame above can finish loading mid-click and push the button away from the pointer.
    find_link("Attach comment").trigger("click")

    select comments.first.tiny_name, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach & Attach another"
      end
      wait_for_loaded
    }.to change(project.comments, :count).by 1

    # The modal reloads after each attach. Selecting before the fresh form lands would pick on the old one.
    within '[aria-modal="true"]' do
      expect(page).to have_select "fields_related_id", selected: I18n.t("avo.choose_an_option")
    end

    select comments.second.tiny_name, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach & Attach another"
      end
      wait_for_loaded
    }.to change(project.comments, :count).by 1

    expect(page).to have_text("Comment attached.").twice
  end

  # User#posts has an attach_scope that hides the posts already attached to the user.
  describe "with an attach_scope" do
    let!(:user) { create(:user) }
    let!(:posts) { create_list(:post, 2) }

    it "removes the attached record from the options" do
      visit avo.resources_user_path(user)

      scroll_to second_tab_group
      click_tab "Posts", within_target: second_tab_group
      click_on "Attach post"

      select posts.first.name, from: "fields_related_id"

      expect {
        within '[aria-modal="true"]' do
          click_on "Attach & Attach another"
        end
        wait_for_loaded
      }.to change(user.posts, :count).by 1

      within '[aria-modal="true"]' do
        expect(page).to have_select "fields_related_id", with_options: [posts.second.name]
        expect(page).not_to have_select "fields_related_id", with_options: [posts.first.name]
      end
    end
  end
end
