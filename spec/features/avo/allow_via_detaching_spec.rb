require "rails_helper"

RSpec.feature "AllowViaDetachings", type: :feature do
  describe "when allowed" do
    let(:team) { create :team }
    let(:review) { create :review, reviewable: team }

    it "is enabled" do
      visit "/admin/resources/reviews/#{review.id}/edit?via_resource_class=TeamResource&via_resource_id=#{team.id}"

      expect(page).to have_field "review_reviewable_type", type: :select, disabled: false
      # review_reviewable_id is disabled because it"s a searchable field
      expect(page).to have_field "review_reviewable_id", type: :text, disabled: true
      # review_user_id is disabled because it"s a searchable field
      expect(page).to have_field "review_user_id", type: :text, disabled: true
    end
  end

  describe "when disallowed" do
    let(:post) { create :post }
    let(:comment) { create :comment, commentable: post }

    it "is enabled" do
      visit "/admin/resources/comments/#{comment.id}/edit?via_resource_class=PostResource&via_resource_id=#{post.id}"

      expect(page).to have_field "comment_commentable_type", type: :select, disabled: true
      expect(page).to have_field "comment_commentable_id", type: :select, disabled: true
      expect(page).to have_field "comment_user_id", type: :select, disabled: false
    end
  end
end
