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

      expect(page).to have_css "turbo-frame[id='summary-frame-status']", visible: false

      find("#summary-header-status").click

      expect(page).to have_css "turbo-frame[id='summary-frame-status']", visible: true

      # I can't make the lazy loading work, looks like it's not triggered at all
      wait_for_turbo_frame_id("summary-frame-status")

      expect(page).to have_css "#status-summary", visible: true
      expect(page).to have_css "#chart-status", visible: true

      within "#status-summary" do
        expect(page).to have_content "REJECTED\n3"
        expect(page).to have_content "CLOSED\n1"
        expect(page).to have_content "LOADING\n4"
      end

      find('th[data-table-header-field-id="status"] div svg').click

      expect(page).not_to have_css "#status-summary"
      expect(page).not_to have_css "#chart-status"
    end

    it "doesn't show up for fields without option" do
      visit avo.resources_projects_path

      expect(page).to have_css 'th[data-table-header-field-id="status"] div svg'
      expect(page).not_to have_css 'th[data-table-header-field-id="progress"] div svg'
      expect(page).not_to have_css 'th[data-table-header-field-id="description"] div svg'
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

        expect(page).to have_css "turbo-frame[id='summary-frame-user']", visible: false

        find("#summary-header-user").click

        expect(page).to have_css "turbo-frame[id='summary-frame-user']", visible: true

        wait_for_turbo_frame_id("summary-frame-user")

        within "#user-summary" do
          expect(page).to have_content "ALICE SMITH"
          expect(page).to have_content "BOB JONES"
          expect(page).not_to have_content "#<"
        end
      end
    end

    context "when filters are applied on the index" do
      it "adjusts the summary to reflect only the filtered records" do
        encoded_filters = Base64.encode64({"Avo::Filters::ProjectStatusFilter" => {"loading" => true}}.to_json)

        visit avo.resources_projects_path(encoded_filters: encoded_filters)

        find("#summary-header-status").click
        wait_for_turbo_frame_id("summary-frame-status")

        within "#status-summary" do
          expect(page).not_to have_content "REJECTED"
          expect(page).not_to have_content "CLOSED"
          expect(page).to have_content "LOADING"
        end
      end
    end

    context "when scopes are applied on the index" do
      before do
        create(:project, stage: "Done")
        create(:project, stage: "On hold")
      end

      it "adjusts the summary to reflect only the scoped records" do
        visit avo.resources_projects_path(scope: "Avo::Scopes::ProjectDone")

        find("#summary-header-stage").click
        wait_for_turbo_frame_id("summary-frame-stage")

        within "#stage-summary" do
          expect(page).to have_content "DONE"
          expect(page).not_to have_content "ON HOLD"
          expect(page).not_to have_content "CANCELLED"
        end
      end
    end

    context "when search is applied on the index" do
      before do
        create(:project, name: "Search summary match", status: :closed)
        create(:project, name: "Search summary mismatch", status: :rejected)
      end

      it "adjusts the summary to reflect only the searched records" do
        visit avo.resources_projects_path(q: "Search summary match")

        find("#summary-header-status").click
        wait_for_turbo_frame_id("summary-frame-status")

        within "#status-summary" do
          expect(page).to have_content "CLOSED"
          expect(page).not_to have_content "REJECTED"
          expect(page).not_to have_content "LOADING"
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

        expect(page).to have_css "turbo-frame[id='summary-frame-status']", visible: false

        find("#summary-header-status").click

        expect(page).to have_css "turbo-frame[id='summary-frame-status']", visible: true

        # I can't make the lazy loading work, looks like it's not triggered at all
        wait_for_turbo_frame_id("summary-frame-status")

        expect(page).to have_css "#status-summary", visible: true
        expect(page).to have_css "#chart-status", visible: true

        within "#status-summary" do
          expect(page).to_not have_content "REJECTED\n3"
          expect(page).to have_content "CLOSED\n1"
          expect(page).to_not have_content "LOADING\n4"
        end

        find('th[data-table-header-field-id="status"] div svg').click

        expect(page).not_to have_css "#status-summary"
        expect(page).not_to have_css "#chart-status"
      end
    end
  end
end
