require "rails_helper"

RSpec.feature "Field Summarizing", type: :system do
  before_all do
    create_list :project, 3, status: :rejected
    create_list :project, 1, status: :closed
    create_list :project, 4, status: :loading
  end

  describe "summarizable field option" do
    it "provides the ability to see the distribution of values, toggleable" do
      visit avo.resources_projects_path

      find('button[popovertarget="summary-popover-status"]').click

      wait_for_turbo_frame_id("summary-popover-status")

      expect(page).to have_css "#status-summary", visible: true
      expect(page).to have_css "#chart-status", visible: true

      within "#status-summary" do
        expect(page).to have_content "REJECTED\n3"
        expect(page).to have_content "CLOSED\n1"
        expect(page).to have_content "LOADING\n4"
      end

      find('button[popovertarget="summary-popover-status"]').click

      expect(page).not_to have_css "#status-summary"
      expect(page).not_to have_css "#chart-status"
    end

    it "doesn't show up for fields without option" do
      visit avo.resources_projects_path

      expect(page).to have_css 'button[popovertarget="summary-popover-status"]'
      expect(page).not_to have_css 'button[popovertarget="summary-popover-progress"]'
      expect(page).not_to have_css 'button[popovertarget="summary-popover-description"]'
    end

    context "when summarizing a belongs_to field" do
      let(:user1) { create :user, first_name: "Alice", last_name: "Smith" }
      let(:user2) { create :user, first_name: "Bob", last_name: "Jones" }

      before do
        create_list :project, 3, user: user1
        create_list :project, 1, user: user2
      end

      it "renders the display name instead of the object inspect string" do
        visit avo.resources_projects_path

        find('button[popovertarget="summary-popover-user"]').click

        wait_for_turbo_frame_id("summary-popover-user")

        within "#user-summary" do
          expect(page).to have_content "ALICE SMITH"
          expect(page).to have_content "BOB JONES"
          expect(page).not_to have_content "#<"
        end
      end
    end

    context "when summarizing on association pages" do
      let(:user) { create :user }
      let!(:project) { create :project, status: :closed, users: [user] }

      it "only shows values from associated record" do
        visit avo.resources_user_path(user)

        scroll_to first_tab_group
        click_tab "Projects", within_target: first_tab_group

        wait_for_turbo_frame_id("has_and_belongs_to_many_field_show_projects")

        find('button[popovertarget="summary-popover-status"]').click

        wait_for_turbo_frame_id("summary-popover-status")

        expect(page).to have_css "#status-summary", visible: true
        expect(page).to have_css "#chart-status", visible: true

        within "#status-summary" do
          expect(page).to_not have_content "REJECTED\n3"
          expect(page).to have_content "CLOSED\n1"
          expect(page).to_not have_content "LOADING\n4"
        end

        find('button[popovertarget="summary-popover-status"]').click

        expect(page).not_to have_css "#status-summary"
        expect(page).not_to have_css "#chart-status"
      end
    end
  end
end
