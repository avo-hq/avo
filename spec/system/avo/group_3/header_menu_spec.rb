require "rails_helper"

# Real-page spec for the navbar header. The DSL-configured path is tested in
# `avo-menu/spec` (which has access to `Avo::Menu::Builder`); here we cover
# only the fallback behavior the avo gem owns.
RSpec.describe "Header menu", type: :system do
  let!(:user) { create :user }

  describe "without `header_menu` configured" do
    it "falls back to an app_name link pointing at /" do
      visit "/admin/resources/users"

      within ".header-menu .header-menu__row" do
        expect(page).to have_selector(
          "a[href='/'].font-semibold",
          visible: :all
        )
      end
    end
  end
end
