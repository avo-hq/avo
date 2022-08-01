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

      expect(page).to have_selector 'table tr:first-child td:first-child[data-control="resource-controls"]'
      expect(page).not_to have_selector 'table tr:first-child td:last-child[data-control="resource-controls"]'
    end
  end

  describe "with controls on the right" do
    it "shows to the right" do
      Avo.configuration.resource_controls_placement = :right
      visit "/admin/resources/comments"

      expect(page).not_to have_selector 'table tr:first-child td:first-child[data-control="resource-controls"]'
      expect(page).to have_selector 'table tr:first-child td:last-child[data-control="resource-controls"]'
    end
  end
end
