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

      # XPath containing the index of the cell
      expect(page).to have_xpath('/html/body/div/div/div[2]/div[2]/div/div/div[1]/div/div[2]/div[2]/div/div/table/tbody/tr[1]/td[1][@data-control="resource-controls"]')
    end
  end

  describe "with controls on the right" do
    it "shows to the right" do
      Avo.configuration.resource_controls_placement = :right
      visit "/admin/resources/comments"

      # XPath containing the index of the cell
      expect(page).to have_xpath('/html/body/div/div/div[2]/div[2]/div/div/div[1]/div/div[2]/div[2]/div/div/table/tbody/tr[1]/td[6][@data-control="resource-controls"]')
    end
  end
end
