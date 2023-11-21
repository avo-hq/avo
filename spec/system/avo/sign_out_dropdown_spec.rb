require "rails_helper"

RSpec.feature "SignOutDropdown", type: :system do
  context "when signed in" do
    it "signs out the user" do
      visit "/admin/resources/posts"

      expect(page.body).to have_text admin.name
      expect(page.body).to have_button "Sign out", visible: false

      dots_button = find("[data-control='profile-dots']")

      dots_button.click

      expect(page.body).to have_button "Sign out", visible: true

      # Test click away
      # FIXME: Selenium::WebDriver::Error::ElementNotInteractableError: element not interactable
      # page.find("body").click
      # expect(page.body).to have_button "Sign out", visible: false

      # dots_button.click
      click_button "Sign out"
      accept_alert
      wait_for_loaded

      expect(current_path).to eql "/users/sign_in"
    end
  end
end
