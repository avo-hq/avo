require "rails_helper"

RSpec.feature "belongs_to", type: :feature do
  let!(:user) { create :user }
  let!(:project) { create :project }

  before do
    # Update admin so it doesn't come up in the search
    admin.update(first_name: "Jim", last_name: "Johnes")
  end

  describe "not searchable" do
    context "new" do
      context "without an association" do
        context "when not filling the poly association" do
          it "creates the comment" do
            visit "/admin/resources/comments/"

            expect(page).to have_text "No record found"

            click_on "Create new comment"
            fill_in "comment_body", with: "Sample comment"
            select user.name, from: "comment_user_id"
            save

            return_to_comment_page

            expect(find_field_value_element("body")).to have_text "Sample comment"
            expect(find_field_value_element("user")).to have_link user.name, href: "/admin/resources/compact_users/#{user.slug}?via_record_id=#{Comment.last.to_param}&via_resource_class=Avo%3A%3AResources%3A%3AComment"
            expect(find_field_value_element("commentable")).to have_text empty_dash
          end
        end
      end

      context "with an association" do
        let!(:comment) { create :comment, commentable: project }

        describe "nullifying a polymorphic association" do
          context "with selecting 'Choose an option'" do
            let!(:project) { create :project }

            it "empties the commentable association" do
              visit "/admin/resources/comments/#{comment.id}/edit"

              select "Choose an option", from: "comment_commentable_type"
              save

              return_to_comment_page

              expect(find_field_value_element("commentable")).to have_text empty_dash
            end
          end
        end
      end
    end

    context "index" do
      describe "without an association" do
        let!(:comment) { create :comment }

        it "displays an empty dash" do
          visit "/admin/resources/comments"

          expect(page.body).to have_text "Commentable"
          expect(field_element_by_resource_id("commentable", comment.id)).to have_text empty_dash
        end
      end

      describe "with a polymorphic relation" do
        let!(:project) { create :project }
        let!(:comment) { create :comment, commentable: project }

        it "displays the commentable label" do
          visit "/admin/resources/comments"

          expect(page.body).to have_text "Commentable"
          expect(field_element_by_resource_id("commentable", comment.id)).to have_link project.name, href: "/admin/resources/projects/#{project.id}"
        end
      end
    end
  end

  describe "with namespaced model" do
    let!(:course) { create :course }

    it "has the prefilled association details" do
      visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_record_id=#{course.to_param}"

      expect(page).to have_field type: :select, name: "course/link[course_id]", disabled: true, text: course.name
      expect(page).to have_field type: :hidden, name: "course/link[course_id]", visible: false, with: course.id
    end
  end
end

def return_to_comment_page
  click_on Comment.first.id.to_s
  wait_for_loaded
end
