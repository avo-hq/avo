require "rails_helper"

RSpec.feature "belongs_to", type: :system do
  let!(:user) { create :user }
  let!(:post) { create :post }
  let!(:second_post) { create :post, name: "Artichokes are good too" }
  # making more posts so we're certain that we check for the right record
  let!(:other_posts) {
    create_list(:post, 10) do |post, i|
      post.update(name: "#{Faker::Company.name} - #{i}")
    end
  }
  let!(:project) { create :project }

  let!(:amber) { create :user, first_name: "Amber", last_name: "Johnes" }
  let!(:alicia) { create :user, first_name: "Alicia", last_name: "Johnes" }
  let!(:post) { create :post, name: "Avocados are the best" }
  let!(:team) { create :team, name: "Apple" }

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

        context "when filling the poly association" do
          describe "creating a polymorphic association" do
            it "creates the comment" do
              expect(Comment.count).to eq 0
              visit "/admin/resources/comments/new"

              expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Choose an option"

              fill_in "comment_body", with: "Sample comment"
              select "Post", from: "comment_commentable_type"
              select post.name, from: "comment_commentable_id"
              click_on "Save"
              wait_for_loaded

              expect(Comment.count).to eq 1
              comment = Comment.first

              expect(current_path).to eq "/admin/resources/comments/#{comment.id}"

              expect(find_field_value_element("body")).to have_text "Sample comment"
              expect(page).to have_link post.name, href: "/admin/resources/posts/#{post.id}?via_resource_class=Comment&via_resource_id=#{Comment.last.id}"

              click_on "Edit"

              expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Post"
              expect(page).to have_select "comment_commentable_id", options: ["Choose an option", post.name, second_post.name, *other_posts.map(&:name)], selected: post.name

              # Switch between types and check that values are kept for each one.
              select "Project", from: "comment_commentable_type"
              expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: "Choose an option"
              select "Post", from: "comment_commentable_type"
              expect(page).to have_select "comment_commentable_id", options: ["Choose an option", post.name, second_post.name, *other_posts.map(&:name)], selected: post.name

              # Switch to Project, select one and save
              select "Project", from: "comment_commentable_type"
              select project.name, from: "comment_commentable_id"
              select "Post", from: "comment_commentable_type"
              select other_posts.last.name, from: "comment_commentable_id"

              click_on "Save"
              wait_for_loaded

              expect(Comment.last.commentable_type).to eql "Post"
              expect(Comment.last.commentable_id).to eql other_posts.last.id
            end
          end
        end
      end

      context "with an association" do
        let!(:comment) { create :comment, commentable: project }

        it "shows the associated record" do
          visit "/admin/resources/comments/#{comment.id}/edit"

          expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Project"
          expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: project.name
        end

        describe "nullifying a polymorphic association" do
          context "with selecting 'Choose an option'" do
            let!(:project) { create :project }

            it "empties the commentable association" do
              visit "/admin/resources/comments/#{comment.id}/edit"

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

            it "changes associated record" do
              visit "/admin/resources/comments/#{comment.id}/edit"

              expect(page).to have_select "comment_commentable_type", options: ["Choose an option", "Post", "Project"], selected: "Project"
              expect(page).to have_select "comment_commentable_id", options: ["Choose an option", project.name], selected: project.name

              select "Post", from: "comment_commentable_type"
              select post.name, from: "comment_commentable_id"
              click_on "Save"

              expect(find_field_value_element("commentable")).to have_text post.name
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

    describe "within a parent model" do
      let!(:project) { create :project }
      let!(:comment) { create :comment, body: "hey there", user: user, commentable: project }

      it "has the associated record details prefilled" do
        visit "/admin/resources/comments/new?via_relation=commentable&via_relation_class=Project&via_resource_id=#{project.id}"

        expect(find("#comment_commentable_type").value).to eq "Project"
        expect(find("#comment_commentable_type").disabled?).to be true
        expect(find("#comment_commentable_id").value).to eq project.id.to_s
        expect(find("#comment_commentable_id").disabled?).to be true
      end

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

          click_on "Save"
          wait_for_loaded

          expect(current_path).to eq "/admin/resources/projects/#{project.id}"

          comment.reload

          expect(comment.commentable_type).to eq "Project"
          expect(comment.commentable.id).to eq project.id
        end
      end
    end
  end

  describe "searchable" do
    context "new" do
      context "without an association" do
        it "searches for a user" do
          visit "/admin/resources/reviews/new"

          expect(page).to have_field "review_user_id"
          expect(page).to have_select "review_reviewable_type", selected: "Choose an option", options: ["Choose an option", "Fish", "Post", "Project", "Team"]

          select "Post", from: "review_reviewable_type"

          expect(page).to have_field "review_reviewable_id", placeholder: 'Choose an option'

          fill_in 'review_body', with: 'Yup'
          find('#review_reviewable_id').click

          write_in_search "A"

          wait_for_search_loaded

          expect(find(".aa-Panel")).to have_content "Avocados"
          expect(find(".aa-Panel")).to have_content "Artichokes"
          expect(find(".aa-Panel")).not_to have_content "TEAMS"

          write_in_search "Avocado"

          wait_for_search_loaded

          select_first_result_in_search
          wait_for_search_to_dissapear

          text_input = find '[name="review[reviewable_id]"][type="text"]', visible: true
          expect(text_input.value).to eq 'Avocados are the best'

          click_on 'Save'

          wait_for_loaded

          review = Review.first

          expect(review.reviewable).to eq post
          expect(page).to have_text("Review was successfully created.").once
          expect(find_field_value_element("reviewable")).to have_text post.name
        end
      end

      context "edit" do
        let!(:review) { create :review, body: "Avo rules", reviewable: post, user: amber }

        context "belongs_to" do
          it "prefills the searchable belongs_to field" do
            visit "/admin/resources/reviews/#{review.id}/edit"

            text_field = find '#review_user_id[type="text"]'
            hidden_field = find '#review_user_id[type="hidden"]', visible: false

            expect(text_field.value).to eq amber.name
            expect(hidden_field.value).to eq amber.id.to_s
          end
        end

        context "belongs_to polymorphic" do
          it "changes the reviewable item" do
            visit "/admin/resources/reviews/#{review.id}/edit"

            expect(page).to have_field "review_reviewable_id", with: post.name
            expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
            expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: post.name
            expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

            fill_in 'review_body', with: 'Avo rules!'
            find('#review_reviewable_id').click

            write_in_search "Artichokes"

            wait_for_search_loaded

            expect(find(".aa-Panel")).not_to have_content "Avocados"
            expect(find(".aa-Panel")).to have_content "Artichokes"

            select_first_result_in_search
            wait_for_search_to_dissapear

            expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: second_post.name
            expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: second_post.id, visible: false

            click_on 'Save'

            wait_for_loaded

            review.reload

            expect(review.reviewable).to eq second_post
            expect(review.body).to eq "Avo rules!"
          end
        end

        it "nullifies the reviewable item" do
          visit "/admin/resources/reviews/#{review.id}/edit"

          expect(page).to have_field "review_reviewable_id", with: post.name
          expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

          fill_in "review_body", with: "Avo rules!"
          find('[data-type="Post"] [data-field-id="reviewable"] [data-action="click->search#clearValue"]').click
          expect(find('[data-type="Post"] [data-field-id="reviewable"]', visible: true)).not_to have_selector '[data-action="click->search#clearValue"]'

          click_on "Save"

          wait_for_loaded

          review.reload

          expect(review.reviewable).to be nil
        end

        it "toggles the reviewable item" do
          visit "/admin/resources/reviews/#{review.id}/edit"

          expect(page).to have_field "review_reviewable_id", with: post.name
          expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

          # Change reviewable to Team and check for empty inputs
          select "Team", from: "review_reviewable_type"

          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: ''
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: '', visible: false

          find('#review_reviewable_id').click
          write_in_search 'Apple'

          wait_for_search_loaded

          expect(find(".aa-Panel")).to have_content "Apple"

          find(".aa-Input").send_keys :arrow_down
          find(".aa-Input").send_keys :return

          sleep 0.5

          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: 'Apple'
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: team.id, visible: false

          # Change reviewable to Fish and check for empty inputs
          select "Fish", from: "review_reviewable_type"

          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: ''
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: '', visible: false

          # Change reviewable to Post and check for inputs filled with the post details
          select "Post", from: "review_reviewable_type"

          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

          # Change reviewable to Team and check for inputs filled with the team details
          select "Team", from: "review_reviewable_type"

          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: 'Apple'
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: team.id, visible: false

          click_on "Save"

          wait_for_loaded

          review.reload

          expect(review.reviewable).to eq team
        end

        it "nullifies the reviewable type" do
          visit "/admin/resources/reviews/#{review.id}/edit"

          expect(page).to have_field "review_reviewable_id", with: post.name
          expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
          expect(page).to have_field type: 'text', name: "review[reviewable_id]", with: post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

          select "Choose an option", from: "review_reviewable_type"

          click_on "Save"

          wait_for_loaded

          review.reload

          expect(review.reviewable).to be nil
        end
      end
    end

    describe "with associated record" do
      it "prefills the associated record details" do
        visit "/admin/resources/reviews/new?via_relation=reviewable&via_relation_class=Team&via_resource_id=#{team.id}"

        expect(find("#review_reviewable_type").value).to eq "Team"
        expect(find("[data-type='Team'] #review_reviewable_id[type='text']").value).to eq team.name
        expect(find("[data-type='Team'] #review_reviewable_id[type='hidden']", visible: false).value).to eq team.id.to_s
      end
    end
  end

  describe "with namespaced model" do
    let!(:course) { create :course }

    it "has the prefilled association details" do
      visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_resource_id=#{course.id}"

      expect(page).to have_field type: "text", name: "course/link[course_id]", disabled: true, with: course.name
      expect(page).to have_field type: "hidden", name: "course/link[course_id]", visible: false, with: course.id
    end
  end
end
