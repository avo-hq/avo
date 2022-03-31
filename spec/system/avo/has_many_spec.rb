require "rails_helper"

RSpec.feature "HasManyField", type: :system do
  let!(:user) { create :user }

  context "show" do
    context "posts -> comments" do
      # Fixes https://github.com/avo-hq/avo/issues/668
      describe "displays has other association fields" do
        let!(:post) { create :post }
        let!(:comment) { create :comment, commentable: post, user: user }

        it "displays the other fields" do
          visit "/admin/resources/posts/#{post.id}/comments?turbo_frame=has_many_field_show_comments"

          row = find("[data-resource-name='comments'][data-resource-id='#{comment.id}']")

          expect(row.find('[data-field-id="user"]').text).to eq user.name
        end
      end
    end

    context "team -> reviews" do
      # Fixes https://github.com/avo-hq/avo/issues/668
      describe "displays has other association fields" do
        let!(:team) { create :team }
        let!(:review) { create :review, reviewable: team, user: user }

        it "displays the other fields" do
          visit "/admin/resources/teams/#{team.id}/reviews?turbo_frame=has_many_field_show_reviews"

          row = find("[data-resource-name='reviews'][data-resource-id='#{review.id}']")

          expect(row.find('[data-field-id="user"]').text).to eq user.name
        end
      end
    end

    describe "delete notification visible" do
      let!(:project) { create :project }
      let!(:comments) { create_list :comment, 3, commentable: project }
      let(:url) { "/admin/resources/projects/#{project.id}" }

      it "shows the notification" do
        visit url

        expect {
          find("[data-resource-id='#{comments.first.id}'] [data-control='destroy']").click
          page.driver.browser.switch_to.alert.accept
          sleep 0.2
          find("[data-resource-id='#{comments.third.id}'] [data-control='destroy']").click
          page.driver.browser.switch_to.alert.accept
          sleep 0.2
        }.to change(Comment, :count).by(-2)

        expect(page).to have_current_path url

        expect(page).not_to have_text comments.first.tiny_name.to_s
        expect(page).not_to have_text comments.third.tiny_name.to_s
        expect(page).to have_text comments.second.tiny_name.to_s

        sleep 0.2
        expect(page).to have_text("Resource destroyed").twice
      end
    end
  end

  describe "searchable" do
    let(:course) { create :course }
    let(:second_course) { create :course }
    let(:link_link) { "https://google.com" }
    let!(:link) { create :course_link, course: course, link: "https://apple.com" }
    let!(:second_link) { create :course_link, course: second_course, link: link_link }
    let(:new_path) { "/admin/resources/courses/#{course.id}/links/new" }

    it "shows the modal title" do
      visit new_path

      expect(page).to have_text "Choose course link"
    end

    it "shows the placeholder" do
      visit new_path

      expect(find("input#fields_related_id[placeholder='Click to choose a link']").value).to eql ""
    end

    it "selects a record in search" do
      visit new_path

      find("#fields_related_id").click

      write_in_search "google"
      wait_for_search_loaded

      expect(find(".aa-Panel")).to have_content link_link

      select_first_result_in_search
      wait_for_search_to_dissapear

      expect(find("#fields_related_id[type='text']").value).to eql link_link
      expect(find("#fields_related_id[type='hidden']", visible: false).value).to eql second_link.id.to_s

      expect {
        click_on "Attach"
        wait_for_loaded
      }.to change(Course.find(course.id).links, :count).by 1

      expect(page).to have_text "Course link attached."
    end
  end
end
