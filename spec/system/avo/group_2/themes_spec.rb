require "rails_helper"

# The cascade, proven in a browser: a picked theme changes the resolved tokens,
# a neutral picked afterwards still wins on top (theme in @layer base, picks
# in @layer components), the tiles preview their own theme's tokens, and the
# pick persists across a reload through the avo.theme cookie.
RSpec.describe "Themes", type: :system do
  let!(:user) { create :user, roles: {admin: true} }

  before do
    login_as user
    visit avo.resources_users_path
  end

  def token(name, selector: "body")
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).getPropertyValue(#{name.to_json}).trim()")
  end

  def open_theme_panel
    find(".color-scheme-switcher--compact .color-scheme-switcher__compact-trigger", visible: :all).click
  end

  it "applies a theme, keeps a neutral pick on top of it, and remembers the theme" do
    paper_accent = token("--color-accent")

    page.execute_script("document.documentElement.classList.add('avo-theme-dracula')")
    expect(token("--color-accent")).not_to eq(paper_accent)
    dracula_accent = token("--color-accent")

    # The picker's neutral classes live in @layer components and beat the theme.
    page.execute_script("document.documentElement.classList.add('neutral-theme-slate')")
    expect(token("--color-avo-neutral-500")).to eq(token("--color-slate-500"))
    expect(token("--color-accent")).to eq(dracula_accent)
    page.execute_script("document.documentElement.classList.remove('avo-theme-dracula', 'neutral-theme-slate')")

    # Pick through the UI and reload: the cookie carries it.
    page.driver.resize_window(900, 900) # compact switcher
    visit avo.resources_users_path
    open_theme_panel
    find('[data-appearance-theme="dracula"]').click
    expect(page).to have_css("html.avo-theme-dracula")

    visit avo.resources_users_path
    expect(page).to have_css("html.avo-theme-dracula")
    expect(token("--color-accent")).to eq(dracula_accent)
  end

  it "previews a theme on hover and reverts on leave" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel
    find('[data-appearance-theme="nord"]').hover
    expect(page).to have_css("html.avo-theme-nord")
    find(".color-scheme-switcher__section-label", match: :first).hover
    expect(page).to have_no_css("html.avo-theme-nord")
    expect(page).to have_css("html.avo-theme-paper")
  end

  it "draws each tile in its own theme's tokens" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel

    nord = token("--color-navbar-background", selector: ".theme-tile.avo-theme-nord")
    solarized = token("--color-navbar-background", selector: ".theme-tile.avo-theme-solarized")
    paper = token("--color-navbar-background", selector: ".theme-tile.avo-theme-paper")

    expect(nord).not_to eq(paper)
    expect(solarized).not_to eq(nord)
    # Sidebar derives from background: re-derived on the tile, not inherited from <html>.
    expect(token("--color-sidebar-background", selector: ".theme-tile.avo-theme-solarized")).not_to eq(token("--color-sidebar-background", selector: ".theme-tile.avo-theme-paper"))
  end

  it "reloads when switching to a theme with partial overrides and shows its partial" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    expect(page).to have_no_css('[data-theme-partial="lagoon"]')

    open_theme_panel
    find('[data-appearance-theme="lagoon"]').click

    expect(page).to have_css('[data-theme-partial="lagoon"]')
    expect(page).to have_css("html.avo-theme-lagoon")
  end
end
