require "rails_helper"

# Real-page spec for the navbar header. The DSL-configured path is tested in
# `avo-menu/spec` (which has access to `Avo::Menu::Builder`); here we cover
# only the unconfigured behavior the avo gem owns.
RSpec.describe "Header menu", type: :system do
  let!(:user) { create :user }

  describe "without `header_menu` configured" do
    it "renders the row empty (no links)" do
      visit "/admin/resources/users"

      expect(page).to have_selector(".header-overflow .header-overflow__row")
      within ".header-overflow .header-overflow__row" do
        expect(page).not_to have_selector("a", visible: :all)
      end
    end
  end
end
