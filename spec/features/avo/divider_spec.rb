require "rails_helper"

RSpec.feature "Divider", type: :feature do
  let!(:user) { create :user }

  before do
    visit "/admin/resources/users"
    click_on "Actions"
  end

  describe "Divider in actions" do
    it "renders divider without label" do
      expect(page.all(".relative.col-span-full.border-t").count).to be >= 1
      unlabeled_dividers = page.all(".relative.col-span-full.border-t").select { |divider| divider.find(".absolute").text.strip.empty? }
      expect(unlabeled_dividers.count).to be > 0
    end

    it "renders divider with label" do
      expect(page).to have_css ".relative.col-span-full.border-t"
      expect(page).to have_content "Other actions"
    end
  end
end
