require "rails_helper"

RSpec.describe "App", type: :system do
  let!(:user) { create :user }

  describe "alerts" do
    let!(:project) { create :project }
    let!(:comment) { create :comment, body: "hey there", user: user, commentable: project }

    it "only displays one alert on record update" do
      visit "/admin/resources/projects/#{project.id}"

      expect(find('turbo-frame[id="has_many_field_show_comments"]')).not_to have_text "Commentable"
      expect(find('turbo-frame[id="has_many_field_show_comments"]')).to have_link comment.id.to_s, href: "/admin/resources/comments/#{comment.id}?via_resource_class=ProjectResource&via_resource_id=#{project.id}"

      within 'turbo-frame[id="has_many_field_show_comments"]' do
        click_on comment.id.to_s
      end

      wait_for_loaded
      click_on "Edit"

      expect(find_field("comment_body").value).to eql "hey there"

      fill_in 'comment_body', with: 'yes'
      click_on 'Save'
      wait_for_loaded

      comment.reload
      expect(comment.body).to eq 'yes'

      expect(current_path).to eq "/admin/resources/projects/#{project.id}"
      expect(page).to have_text("Comment was successfully updated.").once
    end

    it "only displays one alert on record destroy from has_many" do
      visit "/admin/resources/projects/#{project.id}"

      expect(find('turbo-frame[id="has_many_field_show_comments"]')).not_to have_text "Commentable"
      expect(find('turbo-frame[id="has_many_field_show_comments"]')).to have_link comment.id.to_s, href: "/admin/resources/comments/#{comment.id}?via_resource_class=ProjectResource&via_resource_id=#{project.id}"

      destroy_button = find("turbo-frame[id='has_many_field_show_comments'] tr[data-resource-id='#{comment.id}'] button[data-control=\"destroy\"]")

      expect {
        destroy_button.click
        confirm_alert
        wait_for_loaded
      }.to change(Comment, :count).by(-1)

      expect(Comment.count).to eq 0

      expect(page).to have_text("Record destroyed").once
    end
  end
end
