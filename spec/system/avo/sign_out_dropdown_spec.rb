require "rails_helper"

RSpec.feature "SignOutDropdown", type: :system do
  context "when signed in" do
    it "signs out the user" do
      visit "/admin/resources/posts"

      expect(page.body).to have_text admin.name
      expect(page.body).to have_link "Sign out", visible: false

      dots_link = find("[data-control='profile-dots']")

      dots_link.click

      expect(page.body).to have_link "Sign out", visible: true

      # Test click away
      page.find("body").click
      expect(page.body).to have_link "Sign out", visible: false

      dots_link.click
      click_link "Sign out"
      accept_alert
      sleep 0.5
      wait_for_loaded

      expect(current_path).to eql "/users/sign_in"
    end
  end
end
