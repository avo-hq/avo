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
  end

  # ---------------------------------------------------------------
  # Index-level: standard filter + search propagate to the chart
  # ---------------------------------------------------------------

  describe "summarizable with filters on the index" do
    context "when a standard filter is applied" do
      it "adjusts the summary to reflect only the filtered records" do
        encoded_filters = Base64.encode64({"Avo::Filters::ProjectStatusFilter" => {"loading" => true}}.to_json)

        visit avo.resources_projects_path(encoded_filters: encoded_filters)

        find('button[popovertarget="summary-popover-status"]').click
        wait_for_turbo_frame_id("summary-popover-status")

        within "#status-summary" do
          expect(page).not_to have_content "REJECTED"
          expect(page).not_to have_content "CLOSED"
          expect(page).to have_content "LOADING"
        end
      end
    end

    context "when search is applied" do
      before do
        create(:project, name: "Search summary match", status: :closed)
        create(:project, name: "Search summary mismatch", status: :rejected)
      end

      it "adjusts the summary to reflect only the searched records" do
        visit avo.resources_projects_path(q: "Search summary match")

        find('button[popovertarget="summary-popover-status"]').click
        wait_for_turbo_frame_id("summary-popover-status")

        within "#status-summary" do
          expect(page).to have_content "CLOSED"
          expect(page).not_to have_content "REJECTED"
          expect(page).not_to have_content "LOADING"
        end
      end
    end
  end

  # ---------------------------------------------------------------
  # Association contexts: prove the fix reaches AssociationsController
  # + ChartsController, not just the top-level index.
  # ---------------------------------------------------------------

  describe "summarizable on association pages" do
    context "on a has_and_belongs_to_many association (Project → Users)" do
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

    context "on a has_and_belongs_to_many association (Project → Users, active summary)" do
      let!(:project) { create :project }

      before do
        active_user1 = create :user, active: true
        active_user2 = create :user, active: true
        inactive_user = create :user, active: false
        _unassociated = create :user, active: true

        project.users << [active_user1, active_user2, inactive_user]
      end

      it "only shows values from users associated with the project" do
        visit avo.resources_project_path(project)

        users_frame = find("turbo-frame#has_and_belongs_to_many_field_show_users")
        scroll_to users_frame
        wait_for_turbo_frame_id("has_and_belongs_to_many_field_show_users")

        find('button[popovertarget="summary-popover-active"]').click

        wait_for_turbo_frame_id("summary-popover-active")

        within "#active-summary" do
          expect(page).to have_content "2" # 2 active users in project
          expect(page).to have_content "1" # 1 inactive user in project
          # unassociated active user must not be counted
          expect(page).not_to have_content "3"
        end
      end
    end

    context "on a has_many association (User → Posts)" do
      let(:admin) { create :user, roles: {admin: true}, active: false }
      let(:author) { create :user }
      let!(:draft_post) { create :post, user: author, status: :draft, published_at: nil, name: "SearchDraft" }
      let!(:published_post) { create :post, user: author, status: :published, published_at: Time.now, name: "SearchPublished" }
      let!(:archived_post) { create :post, user: author, status: :archived, published_at: nil, name: "ArchivedOne" }
      # Noise: another user's post must not appear in the chart.
      let!(:other_user_post) { create :post, user: create(:user), status: :published, published_at: Time.now, name: "Other" }

      def open_status_summary
        find('button[popovertarget="summary-popover-status"]').click
        wait_for_turbo_frame_id("summary-popover-status")
      end

      it "shows distribution scoped to the parent's records" do
        visit "/admin/resources/users/#{author.id}/posts?view_type=table"
        open_status_summary

        within "#status-summary" do
          expect(page).to have_content "DRAFT\n1"
          expect(page).to have_content "PUBLISHED\n1"
          expect(page).to have_content "ARCHIVED\n1"
        end
      end

      it "adjusts the summary when a standard filter is applied" do
        encoded_filters = Avo::Filters::BaseFilter.encode_filters({"Avo::Filters::PublishedFilter" => "published"})

        visit "/admin/resources/users/#{author.id}/posts?view_type=table&encoded_filters=#{encoded_filters}"
        open_status_summary

        within "#status-summary" do
          expect(page).to have_content "PUBLISHED\n1"
          expect(page).not_to have_content "DRAFT"
          expect(page).not_to have_content "ARCHIVED"
        end
      end

      it "adjusts the summary when search is applied via URL" do
        visit "/admin/resources/users/#{author.id}/posts?view_type=table&q=SearchPublished"
        open_status_summary

        within "#status-summary" do
          expect(page).to have_content "PUBLISHED\n1"
          expect(page).not_to have_content "DRAFT"
          expect(page).not_to have_content "ARCHIVED"
        end
      end

      it "adjusts the summary when search is typed into the input (turbo-stream path)" do
        visit "/admin/resources/users/#{author.id}/posts?view_type=table"

        search_input = find('input[data-resource-search-target="input"]')
        search_input.fill_in with: "SearchDraft"

        expect(page).to have_no_content("SearchPublished")
        expect(page).to have_no_content("ArchivedOne")
        expect(page).to have_content("SearchDraft")

        open_status_summary

        within "#status-summary" do
          expect(page).to have_content "DRAFT\n1"
          expect(page).not_to have_content "PUBLISHED"
          expect(page).not_to have_content "ARCHIVED"
        end
      end
    end

    context "on a has_many :through association (Team → team_members)" do
      let(:admin) { create :user, roles: {admin: true}, active: false }
      let(:team) { create :team }
      let!(:active_member_one) { create :user, first_name: "MemberAlpha", active: true }
      let!(:active_member_two) { create :user, first_name: "MemberBeta", active: true }
      let!(:inactive_member) { create :user, first_name: "MemberGamma", active: false }
      let!(:non_member) { create :user, active: true }

      before do
        TeamMembership.create!(team: team, user: active_member_one, level: "member")
        TeamMembership.create!(team: team, user: active_member_two, level: "member")
        TeamMembership.create!(team: team, user: inactive_member, level: "member")
      end

      def open_active_summary
        find('button[popovertarget="summary-popover-active"]').click
        wait_for_turbo_frame_id("summary-popover-active")
      end

      it "shows distribution scoped to the team's members" do
        visit "/admin/resources/teams/#{team.id}/team_members"
        open_active_summary

        within "#active-summary" do
          expect(page).to have_content "TRUE\n2"
          expect(page).to have_content "—\n1"
        end
      end

      it "adjusts the summary when a standard filter is applied" do
        encoded_filters = Avo::Filters::BaseFilter.encode_filters({"Avo::Filters::UserActiveFilter" => "true"})

        visit "/admin/resources/teams/#{team.id}/team_members?encoded_filters=#{encoded_filters}"
        open_active_summary

        within "#active-summary" do
          expect(page).to have_content "TRUE\n2"
          expect(page).not_to have_content "—"
        end
      end

      it "adjusts the summary when search is applied" do
        visit "/admin/resources/teams/#{team.id}/team_members?q=MemberGamma"
        open_active_summary

        within "#active-summary" do
          expect(page).to have_content "—\n1"
          expect(page).not_to have_content "TRUE"
        end
      end
    end
  end
end
