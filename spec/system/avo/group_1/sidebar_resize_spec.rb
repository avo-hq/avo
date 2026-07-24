require "rails_helper"

# Unit 1 of the resizable-sidebar feature: make `.container-small` fill the space
# left of the sidebar (max-width, not a fixed 960px width) so that a widened
# sidebar no longer overflows show/edit pages.
#
# Isolation note: the cookie -> server parse -> `--sidebar-width-stored` ->
# `--sidebar-width` derivation chain is Unit 2. It does not exist yet, so a cookie
# cannot widen the sidebar in this branch. These specs instead reproduce the exact
# layout condition Unit 1 fixes by forcing `--sidebar-width` directly on the
# sidebar host, which flows through the existing (unchanged) derivation:
#   --sidebar-width -> --sidebar-offset-size -> .main padding-inline-start.
# When Unit 2 lands, the same scenarios can be re-expressed against a real cookie.
RSpec.describe "sidebar resize (Unit 1: .container-small)", type: :system do
  let!(:user) { create :user }

  # `.container-small` is the default container for show/new/edit/create/update.
  let(:show_path) { "/admin/resources/users/#{user.slug}" }

  # Width of the compiled default spacing scale: max-w-240 -> 240 * 0.25rem = 960px.
  let(:container_max_width) { 960 }

  def visit_show_at(width, height)
    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(width, height)
    visit show_path
    # The layout container is always present; wait for it before measuring.
    expect(page).to have_selector(".container-small", visible: :all)
  end

  # Simulate a widened sidebar. Inline styles outrank stylesheet rules, so this
  # stands in for the value Unit 2's carrier will write, and the existing
  # `--sidebar-offset-size: var(--sidebar-width)` derivation picks it up.
  #
  # The .main padding and .main-content width/margin carry a 0.1s transition, so
  # we suppress it first (Unit 2 does the same at runtime via
  # html[data-sidebar-resizing]) and force a reflow, otherwise the measurements
  # below catch the animation mid-flight.
  def force_sidebar_width(px)
    page.execute_script(<<~JS)
      (function () {
        if (!document.getElementById('spec-no-transition')) {
          const s = document.createElement('style');
          s.id = 'spec-no-transition';
          s.textContent = '.main, .main-content { transition: none !important; }';
          document.head.appendChild(s);
        }
        document.querySelector('.main[data-controller~="sidebar"]')
          .style.setProperty('--sidebar-width', '#{px}px');
        void document.documentElement.offsetWidth; // force synchronous reflow
      })()
    JS
  end

  def sidebar_offset
    page.evaluate_script(<<~JS)
      parseFloat(getComputedStyle(
        document.querySelector('.main[data-controller~="sidebar"]')
      ).paddingInlineStart)
    JS
  end

  def no_horizontal_page_scroll?
    page.evaluate_script(
      "document.documentElement.scrollWidth <= document.documentElement.clientWidth"
    )
  end

  def container_width
    page.evaluate_script(
      "document.querySelector('.container-small').getBoundingClientRect().width"
    )
  end

  # Gap between the container and its parent .main-content content box, on each
  # inline side. Equal, positive gaps prove mx-auto centering (and that the flex
  # item did not collapse to its content width against the start edge).
  def container_side_gaps
    page.evaluate_script(<<~JS)
      (function () {
        const c = document.querySelector('.container-small').getBoundingClientRect();
        const parent = document.querySelector('.main-content');
        const pr = parent.getBoundingClientRect();
        const s = getComputedStyle(parent);
        const innerLeft = pr.left + parseFloat(s.borderLeftWidth) + parseFloat(s.paddingLeft);
        const innerRight = pr.right - parseFloat(s.borderRightWidth) - parseFloat(s.paddingRight);
        return { left: c.left - innerLeft, right: innerRight - c.right };
      })()
    JS
  end

  # Happy path / the contract. Catches the Flexbox auto-margin trap: without an
  # explicit `w-full`, mx-auto suppresses align-self: stretch and the container
  # collapses to its content width instead of holding 960px.
  it "renders at exactly 960px and stays centered at 1920x1080 (default sidebar)" do
    visit_show_at(1920, 1080)

    expect(container_width).to be_within(1).of(container_max_width)

    gaps = container_side_gaps
    expect(gaps["left"]).to be > 1            # there IS margin -> centered, not stretched to edge
    expect(gaps["left"]).to be_within(2).of(gaps["right"])
  end

  # Edge case: the defect this unit removes. With a 480px sidebar the fixed-width
  # container overflowed the page horizontally. Fails before the fix, passes after.
  it "produces no horizontal page scroll at 1280x800 with a 480px sidebar" do
    visit_show_at(1280, 800)
    force_sidebar_width(480)

    expect(sidebar_offset).to eq(480)          # guard: the simulation actually widened the offset
    expect(no_horizontal_page_scroll?).to be true
    expect(container_width).to be < (container_max_width - 1)  # filled the reduced space, did not stay 960
  end

  it "produces no horizontal page scroll at 1440x900 with a 480px sidebar" do
    visit_show_at(1440, 900)
    force_sidebar_width(480)

    expect(sidebar_offset).to eq(480)
    expect(no_horizontal_page_scroll?).to be true
    expect(container_width).to be < (container_max_width - 1)
  end

  # Edge case: today's default sidebar is a provable no-op. At 1280px with a 256px
  # sidebar there is still room for the full 960px, so width is unchanged and there
  # is no horizontal scroll.
  it "is unchanged with today's 256px sidebar at 1280x800" do
    visit_show_at(1280, 800)

    expect(no_horizontal_page_scroll?).to be true
    expect(container_width).to be_within(1).of(container_max_width)
  end

  # Edge case (the new coupling): a host override of the width is now silently
  # clamped by the Avo-owned max-width the host never wrote. This makes the
  # documented behavior change visible in the suite. Passes only after the fix
  # (the old fixed `width: 960px` gave the host override nothing to clamp against).
  it "clamps a host `.container-small { width: 1200px }` override to 960px" do
    visit_show_at(1920, 1080)
    page.execute_script(<<~JS)
      const style = document.createElement('style');
      style.textContent = '.container-small { width: 1200px; }';
      document.head.appendChild(style);
    JS

    expect(container_width).to be_within(1).of(container_max_width)
  end
end

# Unit 2 of the resizable-sidebar feature: the cookie -> server parse ->
# `--sidebar-width-stored` (pre-paint carrier) -> lg-gated `--sidebar-width`
# derivation chain, exercised end-to-end against a REAL cookie in the browser.
# The server-rendered half (carrier markup, nonce, no inline style, 500
# prevention) is covered headlessly in
# spec/requests/avo/sidebar_width_request_spec.rb; the parse table is in
# spec/helpers/avo/application_helper_spec.rb. These specs prove the CSS
# derivation and its breakpoint gating in an actual browser, and need the built
# stylesheet (yarn build:css) to see it.
RSpec.describe "sidebar width carrier (Unit 2)", type: :system do
  let!(:user) { create :user }
  let(:some_avo_path) { "/admin/resources/users" }

  # `--sidebar-width` derives from `--sidebar-width-stored` inside the lg media
  # block. When the sidebar is open at >= lg, `.main`'s padding-inline-start
  # equals `--sidebar-offset-size` = `--sidebar-width`, so the offset is the
  # cleanest resolved-to-px read of the derived width (same measure Unit 1 uses).
  def sidebar_offset
    page.evaluate_script(<<~JS)
      parseFloat(getComputedStyle(
        document.querySelector('.main[data-controller~="sidebar"]')
      ).paddingInlineStart)
    JS
  end

  # The raw preference the carrier wrote on <html>. This is a plain `<n>px`
  # custom property (no clamp/var), so getPropertyValue returns it verbatim.
  def stored_px
    page.evaluate_script(<<~JS)
      parseFloat(getComputedStyle(document.documentElement)
        .getPropertyValue('--sidebar-width-stored'))
    JS
  end

  # Mobile sidebar (second .avo-sidebar in DOM order; the first is #main-sidebar,
  # which is display:none below lg). It is laid out below lg, so its width
  # resolves to px. Below lg the derivation is gated off, so it stays 256px.
  def mobile_sidebar_width
    page.evaluate_script(<<~JS)
      parseFloat(getComputedStyle(document.querySelectorAll('.avo-sidebar')[1]).width)
    JS
  end

  # The .main padding and .main-content carry a 0.1s transition; a window resize
  # animates it. Suppress it so measurements don't catch the animation mid-flight
  # (Unit 2 does the same at runtime via html[data-sidebar-resizing]).
  def suppress_transitions
    page.execute_script(<<~JS)
      if (!document.getElementById('spec-no-transition')) {
        const s = document.createElement('style');
        s.id = 'spec-no-transition';
        s.textContent = '.main, .main-content, .avo-sidebar { transition: none !important; }';
        document.head.appendChild(s);
      }
      void document.documentElement.offsetWidth;
    JS
  end

  def has_carrier_script?
    page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('script'))
        .some(function (s) { return s.textContent.indexOf('--sidebar-width-stored') !== -1; })
    JS
  end

  # Establish the origin (first visit) so the cookie can be scoped to a domain,
  # set it, then re-visit so the server parses it and the carrier applies it
  # before paint. Ordering per spec/support/cookie_helpers.rb.
  def visit_with_cookie(value, width, height)
    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(width, height)
    visit "/"
    set_browser_cookie("avo.sidebar.width", value) if value
    visit some_avo_path
    expect(page).to have_selector(".main[data-controller~='sidebar']", visible: :all)
    suppress_transitions
  end

  # Happy path: a stored 384 applies before paint and drives the layout offset.
  it "applies a stored 384px width at 1440px" do
    visit_with_cookie("384", 1440, 900)

    expect(stored_px).to eq(384)
    expect(sidebar_offset).to be_within(1).of(384)
  end

  # R9 (the regression that matters most): no cookie -> no carrier script -> the
  # untouched 256px default. Asserting the script's ABSENCE is the point.
  it "renders the 256px default with no carrier script when no cookie is set" do
    visit_with_cookie(nil, 1440, 900)

    expect(has_carrier_script?).to be(false)
    expect(sidebar_offset).to be_within(1).of(256)
  end

  # R11: a stored value over the viewport max clamps for DISPLAY (via CSS 40vw)
  # without overwriting the stored preference, and widening the viewport restores
  # the full width with no new request (pure CSS re-clamp).
  it "clamps a stored 480px to 40vw on a narrow desktop then restores it when widened" do
    # 1120px keeps us safely >= lg (1024) while 40vw (~448px) < 480, so 40vw binds.
    visit_with_cookie("480", 1120, 900)

    expect(stored_px).to eq(480) # preference untouched
    expected = page.evaluate_script("Math.min(480, 0.4 * window.innerWidth)")
    expect(sidebar_offset).to be_within(2).of(expected)
    expect(sidebar_offset).to be < 480

    # Widen past 1200px so 40vw > 480; the clamp now yields the full 480 with no
    # navigation (no visit call -> proves it is a pure CSS re-clamp).
    Capybara.current_session.current_window.resize_to(1920, 1080)
    suppress_transitions
    expect(sidebar_offset).to be_within(2).of(480)
  end

  # R19: a desktop-chosen width must not become a mobile overlay. The carrier
  # still writes the raw preference on <html>, but the derivation is gated to
  # >= lg, so below lg the sidebar stays 256px. This is the scenario that proves
  # the gated-derivation architecture.
  it "ignores a stored 480px below lg and renders the 256px default" do
    visit_with_cookie("480", 428, 926)

    expect(stored_px).to eq(480) # the preference is present on <html>...
    expect(mobile_sidebar_width).to be_within(1).of(256) # ...but the gate wins
  end

  it "exposes the sidebar width bounds in window.Avo.configuration" do
    visit_with_cookie(nil, 1440, 900)

    bounds = page.evaluate_script("window.Avo.configuration.sidebar")
    expect(bounds["widthMin"]).to eq(200)
    expect(bounds["widthMax"]).to eq(480)
  end
end
