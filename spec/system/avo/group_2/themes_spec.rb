require "rails_helper"

# The cascade and the picker, proven in a browser: a picked theme changes the
# resolved tokens and forces its scheme, the pickers it owns disappear and
# come back without a reload (with the user's own picks restored), the tiles
# preview their own theme's tokens, and the pick persists across a reload
# through the avo.theme cookie.
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

  def picker(target)
    "[data-appearance-target=\"#{target}\"]"
  end

  it "applies a theme, forces its scheme, and remembers the pick" do
    paper_accent = token("--color-accent")

    # The class alone changes the resolved tokens; a neutral pick in @layer
    # components still beats it, which is what lets Paper-style themes leave
    # the pickers open.
    page.execute_script("document.documentElement.classList.add('avo-theme-dracula')")
    expect(token("--color-accent")).not_to eq(paper_accent)
    dracula_accent = token("--color-accent")
    page.execute_script("document.documentElement.classList.add('neutral-theme-slate')")
    expect(token("--color-avo-neutral-500")).to eq(token("--color-slate-500"))
    expect(token("--color-accent")).to eq(dracula_accent)
    page.execute_script("document.documentElement.classList.remove('avo-theme-dracula', 'neutral-theme-slate')")

    # Pick through the UI: Dracula is dark, so <html> goes dark with it.
    page.driver.resize_window(900, 900) # compact switcher
    visit avo.resources_users_path
    expect(page).to have_no_css("html.dark")
    open_theme_panel
    find('[data-appearance-theme="dracula"]').click
    expect(page).to have_css("html.avo-theme-dracula.dark.scheme-dark")

    # Reload: the cookie carries it, server-side this time.
    visit avo.resources_users_path
    expect(page).to have_css("html.avo-theme-dracula.dark")
    expect(token("--color-accent")).to eq(dracula_accent)
  end

  it "hides the pickers a theme owns without a reload and restores the user's picks on the way back" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel

    # On Paper, pick a neutral: the class lands on <html>.
    find('[data-theme="slate"]').click
    expect(page).to have_css("html.neutral-theme-slate")
    expect(page).to have_css(picker("neutralPicker"))
    expect(page).to have_css(picker("schemePicker"))

    # Dracula owns its palette: the sections hide and the neutral pick is lifted.
    find('[data-appearance-theme="dracula"]').click
    expect(page).to have_css("html.avo-theme-dracula")
    expect(page).to have_no_css("html.neutral-theme-slate")
    expect(page).to have_no_css(picker("neutralPicker"))
    expect(page).to have_no_css(picker("accentPicker"))
    expect(page).to have_no_css(picker("schemePicker"))
    expect(page).to have_css(picker("neutralPicker"), visible: :hidden)

    # Back to Paper: the sections return and so does the slate pick.
    find('[data-appearance-theme="paper"]').click
    expect(page).to have_css("html.avo-theme-paper.neutral-theme-slate")
    expect(page).to have_no_css("html.dark")
    expect(page).to have_css(picker("neutralPicker"))
    expect(page).to have_css(picker("accentPicker"))
    expect(page).to have_css(picker("schemePicker"))

    # A reload agrees with the browser: Paper with slate, cookies intact.
    visit avo.resources_users_path
    expect(page).to have_css("html.avo-theme-paper.neutral-theme-slate")
  end

  it "previews a theme on hover, scheme included, and reverts on leave" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel
    find('[data-appearance-theme="nord"]').hover
    expect(page).to have_css("html.avo-theme-nord.dark")
    find(".color-scheme-switcher__section-label", match: :first).hover
    expect(page).to have_no_css("html.avo-theme-nord")
    expect(page).to have_css("html.avo-theme-paper")
    expect(page).to have_no_css("html.dark")
  end

  it "draws each tile in its own theme's tokens, whatever scheme the page is in" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel

    nord = token("--color-navbar-background", selector: ".theme-tile.avo-theme-nord")
    solarized = token("--color-navbar-background", selector: ".theme-tile.avo-theme-solarized_light")
    paper = token("--color-navbar-background", selector: ".theme-tile.avo-theme-paper")

    expect(nord).not_to eq(paper)
    expect(solarized).not_to eq(nord)
    # Sidebar derives from background: re-derived on the tile, not inherited from <html>.
    expect(token("--color-sidebar-background", selector: ".theme-tile.avo-theme-solarized_light")).not_to eq(token("--color-sidebar-background", selector: ".theme-tile.avo-theme-paper"))
    # A dark theme's tile stays dark on this light page.
    expect(token("--color-background", selector: ".theme-tile.avo-theme-nord")).to eq(token("--color-avo-neutral-900", selector: ".theme-tile.avo-theme-nord"))
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
