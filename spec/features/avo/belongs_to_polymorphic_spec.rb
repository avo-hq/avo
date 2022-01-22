require "rails_helper"

RSpec.feature "belongs_to", type: :system do
  let!(:user) { create :user }

  describe "creating a comment" do
    context "without a polymorphic association" do
      it "creates the comment" do
        visit "/admin/resources/comments/"

        expect(page).to have_text "No comments found"

        click_on "Create new comment"
        fill_in "comment_body", with: "Sample comment"
        select user.name, from: "comment_user_id"
        click_on "Save"

        expect(find_field_value_element("body")).to have_text "Sample comment"
        expect(find_field_value_element("user")).to have_link user.name, href: "/admin/resources/users/#{user.slug}?via_resource_class=Comment&via_resource_id=#{Comment.last.id}"
        expect(find_field_value_element("commentable")).to have_text empty_dash
      end
    end

    context "with a polymorphic association" do
      let!(:post) { create :post }
      let!(:project) { create :project }

      describe "creating a polymorphic association" do
        it "creates the comment" do
          visit "/admin/resources/comments/new"

          expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Choose an option"

          fill_in "comment_body", with: "Sample comment"
          select "Post", from: "comment_commentable_type"
          select post.name, from: "comment_commentable_id"
          click_on "Save"

          expect(find_field_value_element("body")).to have_text "Sample comment"
          expect(page).to have_link post.name, href: "/admin/resources/posts/#{post.id}?via_resource_class=Comment&via_resource_id=#{Comment.last.id}"

          click_on "Edit"

          expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Post"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", post.name], selected: post.name

          # Switch between types and check that values are kept for each one.
          select "Project", from: "comment_commentable_type"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: "Choose an option"
          select "Post", from: "comment_commentable_type"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", post.name], selected: post.name

          # Switch to Project, select one and save
          select "Project", from: "comment_commentable_type"
          select project.name, from: "comment_commentable_id"

          click_on "Save"
          wait_for_loaded

          expect(Comment.last.commentable_type).to eql "Project"
          expect(Comment.last.commentable_id).to eql project.id
        end
      end
    end

    describe "nullifying a polymorphic association" do
      context "with selecting 'Choose an option'" do
        let!(:project) { create :project }
        let!(:comment) { create :comment, commentable: project }

        it "empties the commentable association" do
          visit "/admin/resources/comments/#{comment.id}/edit"

          expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Project"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: project.name

          select "Choose an option", from: "comment_commentable_type"
          click_on "Save"

          expect(find_field_value_element("commentable")).to have_text empty_dash
        end
      end

      context "with just selecting a different association" do
        let!(:project) { create :project }
        let!(:comment) { create :comment, commentable: project }

        it "empties the commentable association" do
          visit "/admin/resources/comments/#{comment.id}/edit"

          expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Project"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: project.name

          select "Post", from: "comment_commentable_type"
          click_on "Save"

          expect(find_field_value_element("commentable")).to have_text empty_dash
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

  describe "within a parent model" do
    let!(:project) { create :project }
    let!(:comment) { create :comment, body: "hey there", user: user, commentable: project }

    context "in a project show page" do
      it "has the comment listed" do
        visit "/admin/resources/projects/#{project.id}"

        expect(find('turbo-frame[id="has_many_field_show_comments"]')).not_to have_text "Commentable"
        expect(find('turbo-frame[id="has_many_field_show_comments"]')).to have_link comment.id.to_s, href: "/admin/resources/comments/#{comment.id}?via_resource_class=Project&via_resource_id=#{project.id}"

        click_on comment.id.to_s

        expect(find_field_value_element("body")).to have_text "hey there"
        expect(find_field_value_element("user")).to have_link user.name, href: "/admin/resources/users/#{user.slug}?via_resource_class=Comment&via_resource_id=#{comment.id}"
        expect(find_field_value_element("commentable")).to have_link project.name, href: "/admin/resources/projects/#{project.id}?via_resource_class=Comment&via_resource_id=#{comment.id}"

        click_on "Edit"

        expect(find_field("comment_body").value).to eql "hey there"
        expect(find_field("comment_user_id").value).to eql user.id.to_s
        expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Project", disabled: true
        expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: project.name, disabled: true
      end
    end
  end
end
