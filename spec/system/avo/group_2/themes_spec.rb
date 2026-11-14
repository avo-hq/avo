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

  it "changes density live across tables and navigation and remembers it on other views" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    cell = ".index-field-wrapper--padded"
    expect(token("padding-top", selector: cell)).to eq("16px")
    expect(token("font-size", selector: ".header__title")).to eq("20px")
    expect(token("gap", selector: ".header__controls")).to eq("12px")
    expect(token("padding-top", selector: ".header__controls .button--size-md")).to eq("8px")
    open_theme_panel
    find('button[data-density="tight"]').click
    expect(page).to have_css("html.density-tight:not(.density-normal):not(.density-relaxed)")
    expect(page).to have_css('button[data-density="tight"][aria-pressed="true"]')
    expect(token("padding-top", selector: cell)).to eq("8px")
    expect(token("padding-top", selector: ".sidebar-link")).to eq("3px")
    expect(token("font-size", selector: cell)).to eq("14px")
    expect(token("font-size", selector: ".header__title")).to eq("18px")
    expect(token("line-height", selector: ".header__title")).to eq("22px")
    expect(token("gap", selector: ".header__controls")).to eq("6px")
    expect(token("margin-bottom", selector: ".breadcrumbs")).to eq("8px")
    expect(token("row-gap", selector: ".index-table-view .panel__body > div")).to eq("8px")
    expect(token("padding-top", selector: ".main-content")).to eq("4px")
    expect(token("padding-top", selector: ".header__controls .button--size-md")).to eq("6px")

    visit avo.resources_users_path(view_type: :grid)
    expect(page).to have_css("html.density-tight")
    expect(token("gap", selector: ".grid-wrapper")).to eq("8px")
    expect(token("padding-top", selector: ".grid-card")).to eq("4px")

    visit avo.resources_user_path(user)
    expect(token("padding-top", selector: ".field-wrapper")).to eq("2px")
    expect(token("min-height", selector: '.field-wrapper[data-field-id="id"] .field-wrapper__label')).to eq("32px")
    expect(token("padding-top", selector: '.field-wrapper[data-field-id="id"] .field-wrapper__content')).to eq("3px")
    open_theme_panel
    find('button[data-density="relaxed"]').click
    expect(token("padding-top", selector: ".field-wrapper")).to eq("6px")
    expect(token("min-height", selector: '.field-wrapper[data-field-id="id"] .field-wrapper__label')).to eq("40px")
    expect(token("row-gap", selector: ".panel")).to eq("24px")
    expect(token("font-size", selector: ".header__title")).to eq("22px")
    expect(token("line-height", selector: ".header__title")).to eq("26px")
    expect(token("gap", selector: ".header__controls")).to eq("18px")
    expect(token("padding-top", selector: ".main-content")).to eq("12px")
    expect(page).to have_css("html.density-relaxed:not(.density-tight):not(.density-normal)")
    expect(token("padding-top", selector: ".header__controls .button--size-md")).to eq("10px")

    page.driver.resize_window(1280, 900)
    visit avo.resources_users_path
    find(".color-scheme-switcher--inline button", text: "Density").click
    within(".color-scheme-switcher--inline") do
      expect(page).to have_css('[role="group"][aria-label="Density"]')
      find('button[data-density="normal"]').click
      expect(page).to have_no_css('button[data-density="normal"]')
    end
    expect(page).to have_css("html.density-normal")
    visit avo.resources_users_path
    expect(page).to have_css("html.density-normal")
  end

  it "changes roundness live, independently of density, and remembers the choice" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    button = ".header__controls .button--size-md"
    normal_radius = token("border-top-left-radius", selector: button).to_f
    normal_padding = token("padding-top", selector: button)
    expect(normal_radius).to be > 0
    open_theme_panel

    {square: [0, 0], tight: [0.5, 4], relaxed: [1.5, 14], normal: [1, 8]}.each do |preset, (factor, inner_radius)|
      find("button[data-roundness='#{preset}']").click
      expect(page).to have_css("html.roundness-#{preset}")
      expect(page).to have_css("button[data-roundness='#{preset}'][aria-pressed='true']")
      expect(token("border-top-left-radius", selector: button).to_f).to eq(normal_radius * factor)
      expect(token("border-top-left-radius", selector: ".card__body")).to eq("#{inner_radius}px")
      expect(token("padding-top", selector: button)).to eq(normal_padding)
      expect(token("border-top-right-radius", selector: ".main-content")).to eq("#{(16 * factor).to_i}px")
    end

    find("button[data-roundness='square']").click
    visit avo.resources_user_path(user)
    expect(page).to have_css("html.roundness-square.density-normal")
    expect(token("border-top-left-radius", selector: button)).to eq("0px")

    page.driver.resize_window(1280, 900)
    visit avo.resources_users_path
    find('.color-scheme-switcher--inline button[title="Roundness"]').click
    within(".color-scheme-switcher--inline") do
      expect(page).to have_css("button[data-roundness='square'][aria-pressed='true']")
      find("button[data-roundness='relaxed']").click
      expect(page).to have_no_css("button[data-roundness='relaxed']")
    end
    visit avo.resources_users_path
    expect(page).to have_css("html.roundness-relaxed")
    expect(token("border-top-left-radius", selector: button).to_f).to eq(normal_radius * 1.5)
  end

  it "previews density and roundness on hover without saving, reverting on exit and Escape" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path

    %w[density roundness].each do |dimension|
      open_theme_panel
      find("button[data-#{dimension}='tight']").hover
      expect(page).to have_css("html.#{dimension}-tight")
      find("button[data-#{dimension}='relaxed']").hover
      expect(page).to have_css("html.#{dimension}-relaxed")
      find(".header__title").hover
      expect(page).to have_css("html.#{dimension}-normal")

      find("button[data-#{dimension}='relaxed']").click
      find("button[data-#{dimension}='tight']").hover
      expect(page).to have_css("html.#{dimension}-tight")
      page.send_keys(:escape)
      expect(page).to have_css("html.#{dimension}-relaxed")
      visit avo.resources_users_path
      expect(page).to have_css("html.#{dimension}-relaxed")
    end
  end

  it "changes heading fonts without changing body text and restores the default" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    body_font = token("font-family")
    open_theme_panel

    {redaction: "Redaction 50", playfair_display: "Playfair Display", paper: "Inter"}.each do |id, font|
      find("[data-appearance-theme='#{id}']").click
      expect(page).to have_css("html.avo-theme-#{id}")
      expect(token("font-family", selector: ".header__title")).to include(font)
      expect(token("font-family")).to eq(body_font)
      expect(token("font-family", selector: ".header__description")).to include((id == :playfair_display) ? "Playfair Display" : "Inter")
      expect(page.evaluate_async_script("document.fonts.load(#{"500 20px '#{font}'".to_json}).then(fonts => arguments[0](fonts.length > 0))")).to be(true)
    end
  end

  it "applies a theme, forces its scheme, and remembers the pick" do
    paper_accent = token("--color-accent")
    page.execute_script("document.documentElement.classList.add('neutral-theme-slate')")
    slate_neutral = token("--color-avo-neutral-500")
    page.execute_script("document.documentElement.classList.remove('neutral-theme-slate')")

    # The class alone changes the resolved tokens; a neutral pick in @layer
    # components still beats it, which is what lets Paper-style themes leave
    # the pickers open.
    page.execute_script("document.documentElement.classList.add('avo-theme-dracula')")
    expect(token("--color-accent")).not_to eq(paper_accent)
    dracula_accent = token("--color-accent")
    page.execute_script("document.documentElement.classList.add('neutral-theme-slate')")
    expect(token("--color-avo-neutral-500")).to eq(slate_neutral)
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

  it "lists themes in three groups: both schemes, light, dark" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel

    groups = all(".color-scheme-switcher__theme-group")
    expect(groups.map { |g| g.find(".color-scheme-switcher__theme-group-label").text }).to eq(["LIGHT & DARK", "LIGHT", "DARK"])
    expect(groups[0]).to have_css('[data-appearance-theme="paper"]')
    expect(groups[1]).to have_css('[data-appearance-theme="coastal"]')
    expect(groups[1]).to have_no_css('[data-appearance-theme="nord"]')
    expect(groups[2]).to have_css('[data-appearance-theme="nord"]')
  end

  it "turns transitions off while previewing and back on afterwards" do
    page.driver.resize_window(900, 900)
    visit avo.resources_users_path
    open_theme_panel
    # System tests run with reduced motion, which already snaps the checkbox,
    # so probe with an element that transitions regardless.
    page.execute_script(%(document.body.insertAdjacentHTML("beforeend", '<div id="probe" style="transition: opacity 1s"></div>')))
    expect(token("transition-property", selector: "#probe")).to eq("opacity")

    find('[data-appearance-theme="nord"]').hover
    expect(page).to have_css("html.theme-previewing")
    expect(token("transition-property", selector: "#probe")).to eq("none")

    find(".color-scheme-switcher__section-label", match: :first).hover
    expect(page).to have_no_css("html.theme-previewing")
    expect(token("transition-property", selector: "#probe")).to eq("opacity")
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
    expect(token("background-image", selector: ".main-content")).to include("linear-gradient")
    expect(token("font-family")).to eq("Georgia, serif")

    visit avo.edit_resources_user_path(user)
    expect(token("font-size", selector: "input.input--size-md")).to eq("16px")
  end
end
