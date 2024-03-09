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
  end
end
