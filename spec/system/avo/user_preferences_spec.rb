require "rails_helper"

RSpec.describe "User Preferences Persistence", type: :system do
  let!(:user) { create :user }

  describe "when persistence is configured" do
    let(:preference_store) { {} }

    around do |example|
      store = preference_store
      original = Avo.configuration.user_preferences
      Avo.configuration.user_preferences = {
        load: ->(user:, request:) { store[user.id] || {} },
        save: ->(user:, request:, key:, value:, preferences:) { store[user.id] = preferences }
      }

      example.run

      Avo.configuration.user_preferences = original
    end

    it "shows the Save button in the color scheme switcher" do
      visit "/admin"

      expect(page).to have_css(".color-scheme-switcher__save")
    end

    it "saves preferences when clicking the Save button" do
      visit "/admin"

      # Click dark mode
      find("[data-action='click->color-scheme-switcher#setScheme'][data-scheme='dark']").click

      # Click Save
      find(".color-scheme-switcher__save").click

      # Wait for success feedback
      expect(page).to have_css(".color-scheme-switcher__save--success")
    end

    it "restores preferences after page reload" do
      # Pre-populate the store with dark scheme preference
      preference_store[user.id] = {"color_scheme" => "dark"}

      visit "/admin"

      # The page should have dark mode applied via cookie synced from server preferences
      expect(page).to have_css("html.dark")
    end

    it "shows success feedback that reverts after ~2 seconds" do
      visit "/admin"

      find(".color-scheme-switcher__save").click

      # Success state appears
      expect(page).to have_css(".color-scheme-switcher__save--success")

      # Success state disappears after timeout
      expect(page).not_to have_css(".color-scheme-switcher__save--success", wait: 5)
    end
  end

  describe "when persistence is not configured" do
    around do |example|
      original = Avo.configuration.user_preferences
      Avo.configuration.user_preferences = nil

      example.run

      Avo.configuration.user_preferences = original
    end

    it "does not show the Save button" do
      visit "/admin"

      expect(page).not_to have_css(".color-scheme-switcher__save")
    end

    it "theme switching still works via cookies" do
      visit "/admin"

      # Click dark mode
      find("[data-action='click->color-scheme-switcher#setScheme'][data-scheme='dark']").click

      # Dark mode should be applied immediately via cookie/JS
      expect(page).to have_css("html.dark")
    end
  end

  describe "when user is not signed in" do
    before do
      Avo.configuration.user_preferences = {
        load: ->(user:, request:) { {} },
        save: ->(user:, request:, key:, value:, preferences:) { }
      }
    end

    after do
      Avo.configuration.user_preferences = nil
    end

    it "does not show the Save button for anonymous users" do
      # Sign out current user
      logout

      # Visiting without being signed in should redirect to sign-in
      # or show the page without the Save button
      # Since the dummy app requires authentication, this test verifies
      # the button is not rendered when _current_user is nil
      visit "/admin"

      expect(page).not_to have_css(".color-scheme-switcher__save")
    end
  end
end
