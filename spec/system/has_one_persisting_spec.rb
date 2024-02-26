require "rails_helper"

RSpec.describe "has_one persisting", type: :system do
  describe "has_one persisting" do
    let!(:user) { create :user, id: 39, slug: "amado-armstrong" }
    let!(:comment) { create :comment, body: "This is a comment", user: user }

    context "Main component" do
      it "redirect back after submit the form", js: true do
        visit "/admin/resources/users/amado-armstrong"

        click_link("Main comment")
        scroll_to second_tab_group
        scroll_to find('turbo-frame[id="has_one_field_show_comment"]')

        expect(page).to have_text "This is a comment"

        find("a.button-component[href^='/admin/resources/comments'][href*='/edit']").click

        expect(page).to have_text "This is a comment"

        fill_in "comment_body", with: "This is an updated comment"

        click_button("Save")

        expect(page).to have_current_path("/admin/resources/users/amado-armstrong")

        click_link("Main comment")
        scroll_to second_tab_group
        scroll_to find('turbo-frame[id="has_one_field_show_comment"]')

        expect(page).to have_text "This is an updated comment"
      end

      it "redirects back when cancel is clicked", js: true do
        visit "/admin/resources/users/amado-armstrong"

        click_link("Main comment")
        scroll_to second_tab_group
        scroll_to find('turbo-frame[id="has_one_field_show_comment"]')

        expect(page).to have_text "This is a comment"

        find("a.button-component[href^='/admin/resources/comments'][href*='/edit']").click

        expect(page).to have_text "This is a comment"

        click_link("Cancel")

        expect(page).to have_current_path("/admin/resources/users/amado-armstrong")
      end
    end
  end
end
