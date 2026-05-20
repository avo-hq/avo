require "rails_helper"

RSpec.describe "sidebar", type: :system do
  let!(:user) { create :user }
  let(:sidebar_toggle_selector) { "button[data-action='click->sidebar#toggleSidebarForViewport']" }

  context "desktop" do
    before(:example) do
      Capybara.reset_sessions!
      visit "/"
    end

    it "is open on login" do
      expect(page).to have_selector "div.sidebar-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find(sidebar_toggle_selector)
      expect(page).to have_selector "div.sidebar-open"
      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-open"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-open"
    end

    it "remembers user choice" do
      sidebar_button = page.find(sidebar_toggle_selector)
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

    it "is closed on login" do
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find(sidebar_toggle_selector)
      expect(page).to_not have_selector "div.sidebar-mobile-open"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-mobile-open"

      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end

    it "remains closed on navigation" do
      expect(page).to_not have_selector "div.sidebar-mobile-open"

      visit "/admin/resources/posts"
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end
  end

  context "when sidebar_toggle_visible is false" do
    around do |example|
      original = Avo.configuration.sidebar_toggle_visible
      Avo.configuration.sidebar_toggle_visible = false
      example.run
      Avo.configuration.sidebar_toggle_visible = original
    end

    it "hides the desktop toggle but keeps mobile access" do
      Capybara.reset_sessions!
      Capybara.current_session.current_window.resize_to(1280, 800)
      visit "/"

      expect(page).to_not have_selector(sidebar_toggle_selector, visible: true)

      Capybara.current_session.current_window.resize_to(428, 926)
      sidebar_button = page.find(sidebar_toggle_selector, visible: true)

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-mobile-open"
    end
  end
end
