require "rails_helper"

# Once tippy initialises it lifts `title` and `data-tippy` off the anchor and
# parks the text on `has-data-tippy`, so that is the attribute a live page has.
RSpec.describe "Field tooltips", type: :system do
  let!(:project) { create :project, name: "Apollo", stage: "Done" }

  describe "on the index" do
    it "marks the header label and hovers the value" do
      visit avo.resources_projects_path

      header = find("th[data-table-header-field-id='stage'] .label-tooltip")
      expect(header["has-data-tippy"]).to eq "Where the project is in its lifecycle"
      expect(header).to have_css("svg.label-tooltip__icon")

      badge = find("[data-field-id='stage'] .tooltip-anchor", text: "Done")
      expect(badge["has-data-tippy"]).to eq "Apollo is done"

      badge.hover
      expect(page).to have_css(".tippy-box", text: "Apollo is done")
    end
  end

  describe "on the show page" do
    it "hovers the label and the value separately" do
      visit avo.resources_project_path(project)

      within "[data-field-id='stage']" do
        find(".label-tooltip").hover
      end
      expect(page).to have_css(".tippy-box", text: "Where the project is in its lifecycle")

      within "[data-field-id='stage']" do
        find(".tooltip-anchor", text: "Done").hover
      end
      expect(page).to have_css(".tippy-box", text: "Apollo is done")
    end
  end
end
