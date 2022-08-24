require "rails_helper"

RSpec.describe "CollapsableMenus", type: :system do
  describe "collapsable menu items" do
    let(:selector) { "[data-menu-key-param='avo.127.0.0.1.main_menu.resources.heroicons_solid_building_storefront'][data-controller='menu']" }

    it "collapses the section" do
      visit "/admin/custom_tool"

      expect(page).to have_selector selector
      expect(page).to have_text "EDUCATION"

      first("#{selector} [data-menu-target='svg']").click

      expect(page).not_to have_text "EDUCATION"
    end
  end
end
