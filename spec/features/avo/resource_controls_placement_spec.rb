require 'rails_helper'

RSpec.feature "ResourceControlsPlacement", type: :feature do
  let!(:comment) { create :comment }

  around do |example|
    original_placement = Avo.configuration.resource_controls_placement
    example.run
    Avo.configuration.resource_controls_placement = original_placement
  end

  describe "with controls on the left" do
    it "shows to the left" do
      Avo.configuration.resource_controls_placement = :left
      visit "/admin/resources/comments"

      within find("table") do
        # XPath containing the index of the cell
        expect(page).to have_xpath('tbody/tr[1]/td[1][@data-control="resource-controls"]')
      end
    end
  end

  describe "with controls on the right" do
    it "shows to the right" do
      Avo.configuration.resource_controls_placement = :right
      visit "/admin/resources/comments"

      within find("table") do
        # XPath containing the index of the cell
        expect(page).to have_xpath('tbody/tr[1]/td[6][@data-control="resource-controls"]')
      end
    end
  end
end
