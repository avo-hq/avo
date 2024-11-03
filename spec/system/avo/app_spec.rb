require "rails_helper"

RSpec.describe "App", type: :system do
  let!(:user) { create :user }

  describe "alerts" do
    let!(:project) { create :project }
    let!(:comment) { create :comment, body: "hey there", user: user, commentable: project }

    it "only displays one alert on record update" do
      visit "/admin/resources/projects/#{project.id}"

      scroll_to comments_frame = find('turbo-frame[id="has_many_field_show_comments"]')

      expect(comments_frame).not_to have_text "Commentable"
      expect(comments_frame).to have_link comment.id.to_s, href: "/admin/resources/comments/#{comment.id}?via_record_id=#{project.to_param}&via_resource_class=Project"

      within 'turbo-frame[id="has_many_field_show_comments"]' do
        click_on comment.id.to_s
      end

      wait_for_loaded
      click_on "Edit"

      expect(find_field("comment_body").value).to eql "hey there"

      fill_in "comment_body", with: "yes"
      save

      expect(page).to have_current_path "/admin/resources/projects/#{project.id}"
      expect(page).to have_text("Comment was successfully updated.").once

      comment.reload
      expect(comment.body).to eq "yes"
    end

    it "only displays one alert on record destroy from has_many" do
      visit "/admin/resources/projects/#{project.id}"

      scroll_to comments_frame = find('turbo-frame[id="has_many_field_show_comments"]')

      expect(comments_frame).not_to have_text "Commentable"
      expect(comments_frame).to have_link comment.id.to_s, href: "/admin/resources/comments/#{comment.id}?via_record_id=#{project.to_param}&via_resource_class=Project"

      destroy_button = find("turbo-frame[id='has_many_field_show_comments'] tr[data-resource-id='#{comment.id}'] button[data-control=\"destroy\"]")

      expect {
        accept_custom_alert do
          destroy_button.click
        end
        wait_for_loaded
      }.to change(Comment, :count).by(-1)

      expect(Comment.count).to eq 0

      expect(page).to have_text("Record destroyed").once
    end

    it "destroy from index page" do
      visit "/admin/resources/projects"

      expect {
        accept_custom_alert do
          find("[data-resource-id='#{project.id}'] [data-control='destroy']").click
        end
        wait_for_loaded
      }.to change(Project, :count).by(-1)
    end
  end

  describe "security", js: true do
    let!(:projects) { create_list :project, 2 }

    it "xss in turbo frames 1" do
      visit "/admin/resources/projects?per_page=1&turbo_frame=has_many_field_show_test_xgc2pf%22%3e%3cscript%3ealert(1)%3c%2fscript%3ep9sk5"
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "xss in turbo frames 2" do
      visit '/admin/resources/projects?per_page=1&turbo_frame=has_many_field_show_test_xgc2pf><script>alert("XSS")<%2Fscript>p9sk5'
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
