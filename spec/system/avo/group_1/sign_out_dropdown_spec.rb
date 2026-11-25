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

    it "does not show the page signed out from, or the one before it, when going back after signing out" do
      create :post, name: "Quarterly numbers"

      visit "/admin/resources/posts"
      visit "/admin/resources/posts?per_page=48"
      expect(page).to have_text "Quarterly numbers"
      # A page the browser restores is on screen before any reload, so record what it holds at that moment.
      page.execute_script("addEventListener('pageshow', () => { sessionStorage.restored = document.body.innerText })")

      find(".sidebar-profile__trigger").click
      accept_alert { click_button "Sign out" }
      expect(page).to have_current_path "/users/sign_in"

      2.times do
        page.go_back

        expect(page).to have_current_path "/users/sign_in"
      end
      expect(page.evaluate_script("sessionStorage.restored").to_s).not_to include "Quarterly numbers"
    end

    it "asks the app's own host to clear the browser cache when Avo is mounted at /" do
      allow_any_instance_of(Avo::ApplicationHelper).to receive(:root_path_without_url).and_return("/")
      # The dummy mounts Avo at /admin, so nothing would answer the request at /site_data.
      page.driver.browser.network.blacklist = %r{/site_data}

      visit "/admin/resources/posts"
      find(".sidebar-profile__trigger").click
      accept_alert { click_button "Sign out" }
      expect(page).to have_current_path "/users/sign_in"

      cache_clears = page.driver.browser.network.traffic.map(&:request).select { |request| request.method == "DELETE" }
      expect(cache_clears.map(&:url)).to eq ["#{Capybara.current_session.server.base_url}/site_data"]
    end
  end
end
