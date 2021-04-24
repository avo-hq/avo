require "rails_helper"

RSpec.feature "SignOutDropdown", type: :system do
  context "when signed in" do
    it "signs out the user" do
      visit "/avo/resources/posts"
      expect(page.body).to have_text admin.name
      expect(page.body).to have_button "Sign out", visible: false

      click_on admin.name

      expect(page.body).to have_button "Sign out", visible: true

      # Test click away
      page.find("body").click
      expect(page.body).to have_button "Sign out", visible: false

      click_on admin.name
      click_button "Sign out"

      expect(current_path).to eql "/users/sign_in"
    end
  end
end
