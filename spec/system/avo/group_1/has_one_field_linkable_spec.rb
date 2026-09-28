require "rails_helper"

RSpec.describe "HasOneField linkable", type: :system do
  let(:open_in_new_tab_link) { "a[target='_blank']" }

  describe "with linkable: true" do
    let!(:user) { create :user }
    let!(:team) { create :team }
    let!(:admin_membership) { TeamMembership.create!(team: team, user: user, level: :admin) }

    it "links the has_one panel header to the associated record" do
      visit avo.resources_team_path(team)

      expect(page).not_to have_css("#{open_in_new_tab_link}[href='#{avo.resources_team_path(team)}']")

      admin_frame = has_one_field_wrapper(id: :admin)
      scroll_to admin_frame

      within(admin_frame) { click_on "Load Admin" }
      wait_for_turbo_frame_id("has_one_field_show_admin")

      within admin_frame do
        expect(page).to have_css("#{open_in_new_tab_link}[href='#{avo.resources_user_path(user)}']")
      end
    end
  end

  describe "without linkable" do
    let!(:user) { create :user }
    let!(:fish) { create :fish, user: user }

    it "does not render the link on the has_one panel header" do
      visit avo.resources_user_path(user)

      scroll_to first_tab_group

      click_tab "Fish", within_target: first_tab_group

      fish_frame = has_one_field_wrapper(id: :fish)
      scroll_to fish_frame

      within fish_frame do
        expect(page).to have_text fish.name
        expect(page).not_to have_css(open_in_new_tab_link)
      end
    end
  end
end
