require "rails_helper"

RSpec.feature "AllowViaDetaching", type: :feature do
  describe "when allowed" do
    let(:team) { create :team }
    let(:review) { create :review, reviewable: team }

    it "is enabled" do
      visit "/admin/resources/reviews/#{review.id}/edit?via_record_id=#{team.id}&via_resource_class=Avo::Resources::Team"

      # Searchable is a pro feature so will be disabled even if the field defines it as enabled.
      # That's why all fields are type: :select.
      # Avo::Pro tests allow via detaching on searchable fields.
      expect(page).to have_field "review_reviewable_type", type: :select, disabled: false

      # Capybara removes the content from <template /> tags so we need to manually get them from the resulted HTML.
      # https://github.com/teamcapybara/capybara/issues/2510
      parsed_body = Nokogiri(page.body)

      expect_disabled parsed_body.css("#review_reviewable_id").first, disabled: false
      expect_disabled parsed_body.css("#review_user_id").first, disabled: false
    end
  end

  describe "when disallowed" do
    let(:post) { create :post }
    let(:comment) { create :comment, commentable: post }

    it "is enabled" do
      visit "/admin/resources/comments/#{comment.id}/edit?via_record_id=#{post.id}&via_resource_class=Avo::Resources::Post"

      expect(page).to have_field "comment_commentable_type", type: :select, disabled: true

      # Capybara removes the content from <template /> tags so we need to manually get them from the resulted HTML.
      # https://github.com/teamcapybara/capybara/issues/2510
      parsed_body = Nokogiri(page.body)

      expect_disabled parsed_body.css("#comment_commentable_id").first, disabled: true
      expect_disabled parsed_body.css("#comment_user_id").first, disabled: false
    end
  end
end

def expect_disabled(field, disabled: false)
  disabled_node = field.attribute_nodes.find do |node|
    node.name == "disabled"
  end

  if disabled
    expect(disabled_node).to be_present
  else
    expect(disabled_node).to be_nil
  end
end
