require "rails_helper"

RSpec.feature "Locale selector", type: :system do
  after { Avo.configuration.locale = nil }

  def open_profile_menu
    find(".sidebar-profile__actions button[popovertarget]").click
  end

  def pick_language(name)
    open_profile_menu
    find(".locale-selector__trigger").click
    within(".locale-selector__list") { click_button name }
    wait_for_loaded
  end

  it "switches the viewer's language from the profile menu" do
    visit "/admin/resources/posts"

    open_profile_menu
    expect(page).to have_css(".locale-selector__trigger", text: "Language")
    expect(page).to have_css(".locale-selector__trigger", text: "English")
    expect(page).to have_css(".locale-selector__list", visible: :hidden)

    find(".locale-selector__trigger").click
    within(".locale-selector__list") { click_button "Română" }
    wait_for_loaded

    expect(page).to have_css("html[lang='ro']")
    open_profile_menu
    expect(page).to have_css(".sidebar-profile__sign-out", text: "Delogare")
    find(".locale-selector__trigger").click
    expect(page).to have_css(".locale-selector__item[aria-current='true']", text: "Română")
    expect(page).to have_css(".locale-selector__item[aria-current='true']", count: 1)

    # The choice survives navigation without any param in the URL.
    visit "/admin/resources/comments"
    expect(page).to have_css("html[lang='ro']")
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
