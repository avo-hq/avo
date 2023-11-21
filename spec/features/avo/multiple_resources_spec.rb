require "rails_helper"

RSpec.describe "Multiple resources on same model", type: :feature do
  let(:user) { create :user }

  describe 'each resource' do
    it "returns to parent resource when cancel creation" do
      visit "admin/resources/compact_users/#{user.to_param}/posts?turbo_frame=has_many_field_show_posts"
      expect(current_path).to eql "/admin/resources/compact_users/#{user.to_param}/posts"

      click_on "Create new post"

      expect(page).to have_current_path "/admin/resources/posts/new?via_record_id=#{user.to_param}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3ACompactUser"

      click_on "Cancel"
      expect(current_path).to eql "/admin/resources/compact_users/#{user.to_param}"
    end

    it "returns to parent resource when creating new associated record" do
      visit "admin/resources/compact_users/#{user.to_param}/posts?turbo_frame=has_many_field_show_posts"
      expect(current_path).to eql "/admin/resources/compact_users/#{user.to_param}/posts"

      click_on "Create new post"

      expect(page).to have_current_path "/admin/resources/posts/new?via_record_id=#{user.to_param}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3ACompactUser"

      fill_in "post_name", with: "I'm a post from compact user!"

      click_on "Save"
      expect(current_path).to eql "/admin/resources/compact_users/#{user.to_param}"
    end
  end
end
