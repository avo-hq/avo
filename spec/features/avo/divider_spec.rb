require "rails_helper"

RSpec.feature "Divider", type: :feature do
  let!(:user) { create :user }

  before do
    visit "/admin/resources/users"
    click_on "Actions"
    @parsed_body = Nokogiri::HTML(page.body)
    @dividers = @parsed_body.css(".relative.col-span-full.border-t")
  end

  describe "Divider in actions" do
    it "renders divider without label" do
      unlabeled_dividers = @dividers.select { |divider| divider.at_css(".absolute").text.strip.empty? }
      expect(unlabeled_dividers.count).to be > 0
    end

    it "renders divider with label" do
      expect(page).to have_css ".relative.col-span-full.border-t"
      expect(@dividers.text.strip).to eq("Other actions")
    end
  end
end
