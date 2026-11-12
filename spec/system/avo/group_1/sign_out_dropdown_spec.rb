require "rails_helper"

RSpec.feature "SignOutDropdown", type: :system do
  context "when signed in" do
    it "signs out the user" do
      visit "/admin/resources/posts"

      expect(page.body).to have_text admin.name
      expect(page.body).to have_css("form[data-controller='sign-out'][data-action='submit->sign-out#handle']", visible: false)

      profile_trigger = find(".sidebar-profile__trigger")

      profile_trigger.click

      expect(page.body).to have_css("form[data-controller='sign-out'][data-action='submit->sign-out#handle']", visible: true)

      # The menu spans the whole profile row, not just the button that opened it.
      widths = page.evaluate_script(<<~JS)
        [".sidebar-profile__trigger", ".sidebar-profile__dropdown:popover-open"]
          .map((selector) => Math.round(document.querySelector(selector).getBoundingClientRect().width))
      JS
      expect(widths.last).to be >= widths.first

      # Test click away
      all("div", text: "No record found").first.click
      expect(page.body).to have_css("form[data-controller='sign-out'][data-action='submit->sign-out#handle']", visible: false)

      profile_trigger.click

      accept_alert do
        within "form[data-controller='sign-out'][data-action='submit->sign-out#handle']" do
          click_button "Sign out"
        end
      end

      wait_for_loaded

      expect(current_path).to eql "/users/sign_in"
    end
  end
end
