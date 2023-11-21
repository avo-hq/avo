require "rails_helper"

RSpec.feature "AllowViaDetachings", type: :feature do
  describe "when allowed" do
    let(:team) { create :team }
    let(:review) { create :review, reviewable: team }

    it "is enabled" do
      visit "/admin/resources/reviews/#{review.id}/edit?via_record_id=#{team.id}&via_resource_class=Avo::Resources::Team"

      # Searchable is a pro feature so will be disabled even if the field defines it as enabled.
      # That's why all fields are type: :select.
      # Avo::Pro tests allow via detachings on searchable fields.
      expect(page).to have_field "review_reviewable_type", type: :select, disabled: false
      expect(page).to have_field "review_reviewable_id", type: :select, disabled: false
      expect(page).to have_field "review_user_id", type: :select, disabled: false
    end
  end

  describe "when disallowed" do
    let(:post) { create :post }
    let(:comment) { create :comment, commentable: post }

    it "is enabled" do
      visit "/admin/resources/comments/#{comment.id}/edit?via_record_id=#{post.id}&via_resource_class=Avo::Resources::Post"

      expect(page).to have_field "comment_commentable_type", type: :select, disabled: true
      expect(page).to have_field "comment_commentable_id", type: :select, disabled: true
      expect(page).to have_field "comment_user_id", type: :select, disabled: false
    end
  end
end
