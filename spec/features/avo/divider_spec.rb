require "rails_helper"

RSpec.feature "Divider", type: :feature do
  let!(:user) { create :user }

  before do
    visit "/admin/resources/users"
    click_on "Actions"
  end

  describe "Divider in actions" do
    it "renders divider without label" do
      dividers = page.all(".relative.col-span-full.border-t")
      second_divider = dividers[1]
      expect(second_divider).to have_css(".absolute", text: "")
    end

    it "renders divider with label" do
      expect(page).to have_css ".relative.col-span-full.border-t"
      dividers = page.all(".relative.col-span-full.border-t")
      expect(dividers.first.find(".absolute").text.strip).to eq "Other actions"
      expect(page).to have_content "Other actions"
    end
  end
end
