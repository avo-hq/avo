require "rails_helper"

RSpec.feature "AfterCreateUpdatePath", type: :feature do
  describe "after_create_path" do
    it "redirects to index" do
      visit "/admin/resources/comments/new"

      fill_in "comment_body", with: "Something"

      click_on "Save"

      expect(current_path).to eq "/admin/resources/comments"
    end
  end

  describe "after_update_path" do
    let!(:comment) { create :comment }

    it "redirects to index" do
      visit "/admin/resources/comments/#{comment.id}/edit"

      fill_in "comment_body", with: "Something else"

      click_on "Save"

      expect(current_path).to eq "/admin/resources/comments"
    end
  end
end
