require "rails_helper"

RSpec.feature "CustomTools", type: :feature do
  describe "custom tool" do
    before do
      visit "/admin"
    end

    subject { page.body }

    it { is_expected.to have_link "Custom tool", href: /.*\/admin\/custom_tool/ }

    it "navigates to the custom tool page" do
      subject

      click_on_sidebar_item "Custom tool"

      expect(page.body).to have_text "What a nice new tool"
      expect(page.body).to have_text "app/views/avo/tools/custom_tool.html.erb"
      expect(page.body).to have_text "app/views/avo/sidebar/items/_custom_tool.html.erb"
      expect(find(".text-sm.italic")).to have_text "This is the panels tools section."
      expect(find(".breadcrumbs")).to have_text "Dashboard"
    end
  end
end
