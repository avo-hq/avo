require "rails_helper"

RSpec.feature "Divider", type: :feature do
  let!(:user) { create :user }

  before do
    visit "/admin/resources/users"
    click_on "Actions"
  end

  describe "Divider in actions" do
    it "renders divider without label" do
      dividers = page.all("[data-component-name='avo/divider_component']")
      second_divider = dividers[1]
      expect(second_divider).not_to have_selector(".absolute.inset-auto.rounded")
    end

    it "renders divider with label" do
      dividers = page.all("[data-component-name='avo/divider_component']")
      expect(dividers.first.find(".absolute.inset-auto.rounded").text.strip).to eq "Other actions"
      expect(page).to have_content "Other actions"
    end
  end
end
