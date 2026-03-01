require "rails_helper"

RSpec.describe "sidebar", type: :system do
  let!(:user) { create :user }

  context "desktop" do
    before(:example) do
      Capybara.reset_sessions!
      visit "/"
    end

    it "is open on login" do
      expect(page).to have_selector "div.sidebar-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      expect(page).to have_selector "div.sidebar-open"
      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-open"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-open"
    end

    it "remembers user choice" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebar']")
      sidebar_button.click

      visit "/admin/resources/users"

      expect(page).to_not have_selector "div.sidebar-open"
    end
  end

  context "mobile" do
    before(:example) do
      Capybara.reset_sessions!
      Capybara.current_session.current_window.resize_to(428, 926)
      visit "/"
    end

    it "is open on login" do
      expect(page).to have_selector "div.sidebar-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebarOnMobile']")
      expect(page).to have_selector "div.sidebar-open"

      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-open"
    end

    it "remains closed on navigation" do
      sidebar_button = page.find("button[data-action='click->sidebar#toggleSidebarOnMobile']")
      # Ensure we're closed
      sidebar_button.click if page.has_selector?("div.sidebar-open")

      visit "/admin/resources/posts"
      expect(page).to_not have_selector "div.sidebar-open"
    end
  end
end
