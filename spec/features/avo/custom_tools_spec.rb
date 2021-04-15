require "rails_helper"

RSpec.feature "CustomTools", type: :feature do
  describe "custom tool" do
    before do
      visit "/avo"
    end

    subject { page.body }

    it { is_expected.to have_link "Dashboard", href: "/avo/dashboard" }

    it "navigates to the custom tool page" do
      subject

      click_on "Dashboard"

      expect(page.body).to have_text "What a nice new tool"
      expect(page.body).to have_text "app/views/avo/tools/dashboard.html.erb"
      expect(page.body).to have_text "app/views/avo/sidebar/items/_dashboard.html.erb"
      expect(find(".text-2xl.tracking-normal.font-bold.text-gray-800.truncate")).to have_text "Dashboard"
      expect(find(".breadcrumbs")).to have_text "Dashboard"
    end
  end
end
