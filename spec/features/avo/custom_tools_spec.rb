require "rails_helper"

RSpec.feature "CustomTools", type: :feature do
  describe "custom tool" do
    before do
      visit "/avo"
    end

    subject { page.body }

    it { is_expected.to have_link "Custom tool", href: "/avo/custom_tool" }

    it "navigates to the custom tool page" do
      subject

      click_on "Custom tool"

      expect(page.body).to have_text "What a nice new tool"
    end
  end
end
