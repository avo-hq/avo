require "rails_helper"

RSpec.feature "Locale selector", type: :system do
  after { Avo.configuration.locale = nil }

  def open_profile_menu
    find(".sidebar-profile__actions button[popovertarget]").click
  end

  def open_locale_menu
    find(".top-navbar__end .locale-selector__trigger").click
  end

  def pick_language(name)
    open_locale_menu
    within(".locale-selector__panel") { click_button name }
    wait_for_loaded
  end

  it "switches the viewer's language from the top navbar" do
    visit "/admin/resources/posts"

    expect(page).to have_css(".top-navbar__end .locale-selector__trigger[aria-label='Language: English']", text: "EN")
    expect(page).to have_css(".locale-selector__panel", visible: :hidden)

    open_locale_menu
    within(".locale-selector__panel") { click_button "Română" }
    wait_for_loaded

    expect(page).to have_css("html[lang='ro']")
    expect(page).to have_css(".locale-selector__trigger", text: "RO")
    open_profile_menu
    expect(page).to have_css(".sidebar-profile__sign-out", text: "Delogare")
    find("body").send_keys(:escape)
    open_locale_menu
    expect(page).to have_css(".locale-selector__item[aria-current='true']", text: "Română")
    expect(page).to have_css(".locale-selector__item[aria-current='true']", count: 1)

    # The choice survives navigation without any param in the URL.
    visit "/admin/resources/comments"
    expect(page).to have_css("html[lang='ro']")
  end

  it "filters a long list as the viewer types" do
    visit "/admin/resources/posts"
    open_locale_menu

    within(".locale-selector__panel") do
      find("input[type='search']").fill_in with: "rom"
      expect(page).to have_css(".locale-selector__item", text: "Română")
      expect(page).not_to have_css(".locale-selector__item", text: "Deutsch")
    end
  end

  it "flips the page to right-to-left for Arabic" do
    visit "/admin/resources/posts"
    expect(page).to have_css("html[dir='ltr']")

    pick_language "العربية"

    expect(page).to have_css("html[lang='ar'][dir='rtl']")
  end

  it "keeps each viewer's language separate" do
    other_admin = create :user, roles: {admin: true}

    visit "/admin/resources/posts"
    pick_language "Română"
    expect(page).to have_css("html[lang='ro']")

    using_session :other_viewer do
      login_as other_admin, scope: :user
      visit "/admin/resources/posts"

      expect(page).to have_css("html[lang='en']")
      open_profile_menu
      expect(page).to have_css(".sidebar-profile__sign-out", text: "Sign out")
    end

    expect(Avo.configuration.locale).to be_nil
  end
end
