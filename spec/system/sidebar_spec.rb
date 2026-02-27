require "rails_helper"

RSpec.describe "sidebar", type: :system do
  let!(:user) { create :user }

  context "desktop" do
    before(:example) do
      visit "/"
    end

    it "is open on login" do
      expect(page).to have_selector "div.sidebar-open"
    end

    it "toggles between open, collapsed, and closed" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      expect(page).to have_selector "div.sidebar-open"
      sidebar_button.click
      expect(page).to have_selector "div.sidebar-collapsed"

      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-open"
      expect(page).to_not have_selector "div.sidebar-collapsed"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-open"
    end

    it "remembers user choice" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      sidebar_button.click

      visit "/admin/resources/users"

      expect(page).to have_selector "div.sidebar-collapsed"
      sidebar_button.click

      visit "/admin/resources/posts"
      expect(page).to_not have_selector "div.sidebar-open"
      expect(page).to_not have_selector "div.sidebar-collapsed"
    end
  end

  context "mobile" do
    before(:example) do
      Capybara.current_session.current_window.resize_to(428, 926)
      visit "/"
    end

    it "is collapsed on login" do
      expect(page).to have_selector "div.sidebar-collapsed"
      expect(page).to_not have_selector "div.avo-sidebar.hidden", visible: false
    end

    it "toggles between collapsed and open" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebarOnMobile']")
      expect(page).to have_selector "div.sidebar-collapsed"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-open"
      expect(page).to_not have_selector "div.sidebar-collapsed"
      expect(page).to have_selector "div.avo-sidebar", visible: true
    end

    it "remains collapsed on navigation" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebarOnMobile']")
      # Ensure we're collapsed
      if page.has_selector?("div.sidebar-open")
        sidebar_button.click
      end

      visit "/admin/resources/posts"
      expect(page).to have_selector "div.sidebar-collapsed"
    end
  end
end
