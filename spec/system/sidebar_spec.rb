require "rails_helper"

RSpec.describe "sidebar", type: :system do
  let!(:user) { create :user }

  context "desktop" do
    before(:example) do
      visit '/'
    end

    it "is open on login" do
      expect(page).to have_selector 'div.sidebar-open'
    end

    it "toggles between open and closed" do
      visit '/'

      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      expect(page).to have_selector 'div.sidebar-open'
      sidebar_button.click
      expect(page).to_not have_selector 'div.sidebar-open'
    end

    it "remembers user choice" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      sidebar_button.click

      visit '/admin/resources/users'

      expect(page).to_not have_selector 'div.sidebar-open'
      sidebar_button.click

      visit '/admin/resources/posts'
      expect(page).to have_selector 'div.sidebar-open'
    end
  end
end
