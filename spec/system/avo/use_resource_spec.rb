# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Post comments use_resource PhotoComment", type: :system do
  let!(:post) { create :post, user: admin }
  let!(:comments) { create_list :comment, 20, commentable: post }
  let!(:comment) { create :comment, user: admin }

  describe "tests" do
    it "if attach persist" do
      visit avo.resources_post_path(post)

      scroll_to find('turbo-frame[id="has_many_field_show_photo_comments"]')

      click_on "Attach photo comment"

      expect(page).to have_text "Choose photo comment"
      expect(page).to have_select "fields_related_id"

      select comment.tiny_name, from: "fields_related_id"

      click_on "Attach"
      expect(page).to have_text "Photo comment attached."
      expect(page).to have_text comment.tiny_name
    end
  end
end
