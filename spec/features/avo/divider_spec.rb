require "rails_helper"

RSpec.feature "Divider", type: :feature do
  let!(:user) { create :user }

  before do
    visit "/admin/resources/users"
  end

  describe "Divider in actions" do
    let(:dividers) { page.all("[data-component-name='avo/divider_component']", visible: false) }
    it "renders divider without label" do
      expect(dividers[1]).not_to have_selector(".absolute.inset-auto.rounded-sm", visible: false)
    end

    it "renders divider with label" do
      expect(dividers.first.text(:all).strip).to eq "Other actions"
    end
  end
end
