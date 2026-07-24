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

# Unit 5 of the resizable-sidebar feature: the handle itself — geometry, gating,
# and the "it changes nothing for non-resizers" contract. It does not drag yet
# (Unit 6), so everything here is static rendering, CSS gates and hit testing.
#
# Needs the built stylesheet (yarn build:css) and JS bundle (yarn build:js): the
# handle ships `hidden` from the server and the sidebar_resize controller is the
# only thing that removes it.
RSpec.describe "sidebar resize handle (Unit 5)", type: :system do
  let!(:user) { create :user }
  let(:index_path) { "/admin/resources/users" }
  let(:show_path) { "/admin/resources/users/#{user.slug}" }

  # Establishes the origin, optionally sets cookies, then loads an Avo page and
  # waits for the controller to have run (or for it to have decided to keep the
  # handle hidden). Mirrors visit_with_cookie in the Unit 2 group.
  def visit_avo(path = index_path, width: 1440, height: 900, cookies: {})
    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(width, height)
    visit "/"
    cookies.each { |name, value| set_browser_cookie(name, value) }
    visit path
    expect(page).to have_selector(".sidebar-resize-handle", visible: :all)
  end

  def handle_rect
    page.evaluate_script(
      "document.querySelector('.sidebar-resize-handle').getBoundingClientRect().toJSON()"
    )
  end

  # The desktop sidebar (the mobile one is a separate .avo-sidebar, lg:hidden).
  def sidebar_rect
    page.evaluate_script(
      "document.querySelector('#main-sidebar .avo-sidebar').getBoundingClientRect().toJSON()"
    )
  end

  def handle_hidden?
    page.evaluate_script("document.querySelector('.sidebar-resize-handle').hidden")
  end

  def handle_display
    page.evaluate_script(
      "getComputedStyle(document.querySelector('.sidebar-resize-handle')).display"
    )
  end

  # display:none / hidden take an element out of the tab order, and .focus() is
  # a faithful proxy: it is a no-op on an unfocusable element. A literal tab walk
  # would be flaky and prove the same thing.
  def handle_focusable?
    page.evaluate_script(<<~JS)
      (function () {
        const handle = document.querySelector('.sidebar-resize-handle');
        handle.focus();
        return document.activeElement === handle;
      })()
    JS
  end

  def element_at(x, y)
    page.evaluate_script(
      "(document.elementFromPoint(#{x}, #{y}) || {}).className || ''"
    )
  end

  context "at >= lg with the sidebar open" do
    before { visit_avo }

    # Happy path: revealed by the controller, 15px wide, and pinned to the seam.
    # The strip is [edge - 2px, edge + 13px] — biased into the content so the
    # sidebar's 8px scroll gutter stays grabbable, and stopping short of the
    # first interactive element (see the geometry note in
    # css/components/sidebar_resize.css).
    it "reveals a 15px handle straddling the sidebar's end edge" do
      expect(handle_hidden?).to be(false)

      handle = handle_rect
      expect(handle["width"]).to eq(15)
      expect(handle["left"]).to be_within(1).of(sidebar_rect["right"] - 2)
      expect(handle["top"]).to be_within(1).of(48) # --top-navbar-height, 3rem
    end

    # Happy path (discoverability). R12 removed the wrapped labels that would
    # otherwise prompt discovery, so the idle cursor is the affordance's only
    # remaining signal — it is a deliverable, not a nicety.
    it "shows a col-resize cursor at rest" do
      expect(
        page.evaluate_script("getComputedStyle(document.querySelector('.sidebar-resize-handle')).cursor")
      ).to eq("col-resize")
    end

    # "A user who never touches the divider sees today's layout." The at-rest
    # divider is .main-content's own border-s; the handle's ::before seam must
    # stay transparent so no second hairline appears 2px away on every page.
    it "draws no second hairline at rest" do
      expect(
        page.evaluate_script(
          "getComputedStyle(document.querySelector('.sidebar-resize-handle'), '::before').backgroundColor"
        )
      ).to eq("rgba(0, 0, 0, 0)")
    end

    it "is reachable by keyboard" do
      expect(handle_focusable?).to be(true)
    end

    # R3: the grab zone must not eat sidebar clicks. 6px inside the seam is
    # outside the strip (which bites only 2px in), so it belongs to the sidebar.
    it "does not swallow clicks inside the sidebar" do
      edge = sidebar_rect["right"]
      y = 300

      expect(element_at(edge - 6, y)).not_to include("sidebar-resize-handle")
      expect(element_at(edge + 8, y)).to include("sidebar-resize-handle")
    end

    # Integration: the navbar sits at z-400, above the handle's 100, so the
    # toggle stays clickable where it overlaps the strip.
    it "keeps the navbar above the handle" do
      expect(
        page.evaluate_script("getComputedStyle(document.querySelector('.top-navbar')).zIndex").to_i
      ).to be > page.evaluate_script("getComputedStyle(document.querySelector('.sidebar-resize-handle')).zIndex").to_i
    end
  end

  # R18: below lg the sidebar is not resizable. Pure CSS — `display: none` also
  # drops the element from the tab order with no JS involved.
  it "is display:none and unfocusable below lg" do
    visit_avo(width: 900, height: 800)

    expect(handle_display).to eq("none")
    expect(handle_focusable?).to be(false)
  end

  # R20: no handle when the sidebar is closed, and no orphaned tab stop.
  it "stays hidden and unfocusable with the sidebar closed" do
    visit_avo(cookies: {"avo.sidebar.open" => "0"})

    expect(handle_hidden?).to be(true)
    expect(handle_focusable?).to be(false)
  end

  # R22: in RTL the sidebar sits on the right, so the handle must mirror onto
  # its left edge. Everything positional here is a logical property, so flipping
  # `dir` at runtime exercises the same rules the server would render.
  it "mirrors onto the sidebar's left edge in RTL" do
    visit_avo

    page.execute_script("document.documentElement.dir = 'rtl'")

    handle = handle_rect
    expect(handle["left"]).to be_within(1).of(sidebar_rect["left"] - 13)
  end

  # The permanent invariant, and the reason the strip is 15px rather than the
  # 24px WCAG SC 2.5.8 asks for. It reaches 13px into .main-content, which looks
  # like it has 17px to spare on a show page at >= xl (1px border + 16px padding,
  # since .container-small zeroes the inner 8px) — but the first breadcrumb pulls
  # its 4px of padding back out for optical alignment, so +13px is the real
  # ceiling. At 24px the strip covered the start edge of every breadcrumb link,
  # panel body and panel button.
  # Nothing interactive may start inside the strip — not in Avo, not in a paid
  # gem, not in a host's custom field. This is the test that binds all of them.
  #
  # tabindex="-1" elements are excluded: #main-sidebar, .main-content and
  # .panel__body[data-content-focus] are programmatic focus targets (skip links,
  # content focus), not pointer targets, and they legitimately start at the
  # padding edge.
  it "covers no interactive element's start edge on a show page at 1280px with a 480px sidebar" do
    visit_avo(show_path, width: 1280, height: 800, cookies: {"avo.sidebar.width" => "480"})

    offenders = page.evaluate_script(<<~JS)
      (function () {
        const handle = document.querySelector('.sidebar-resize-handle');
        const strip = handle.getBoundingClientRect();

        return Array.from(
          document.querySelectorAll('a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])')
        )
          .filter(function (el) { return el !== handle && el.offsetParent !== null; })
          .filter(function (el) {
            const r = el.getBoundingClientRect();
            return r.width > 0 && r.left >= strip.left && r.left < strip.right;
          })
          .map(function (el) { return el.tagName + '.' + el.className; });
      })()
    JS

    # Guard: the sidebar really is at the maximum, so the strip is where we think.
    expect(handle_rect["left"]).to be_within(1).of(478)
    expect(handle_rect["right"]).to be_within(1).of(493)
    expect(offenders).to be_empty
  end
end

# Units 6 and 7 of the resizable-sidebar feature: the drag itself and what it
# commits. Driven with Ferrum's real mouse (page.driver.browser.mouse), not
# synthetic events, so pointerdown/move/up go through Chrome's real input path.
#
# Note on why the controller binds pointermove/up to `window` rather than to the
# handle: setPointerCapture reports success here (hasPointerCapture is true) but
# Chrome does not retarget CDP-synthesized moves, so a capture-dependent drag
# tracks nothing under automation. Binding to window makes the drag work whether
# or not capture holds — and is what lets these specs exercise it at all.
RSpec.describe "sidebar resize drag (Units 6-7)", type: :system do
  let!(:user) { create :user }
  let(:index_path) { "/admin/resources/users" }
  let(:default_width) { 256 }

  def visit_avo(width: 1440, height: 900, cookies: {})
    Capybara.reset_sessions!
    Capybara.current_session.current_window.resize_to(width, height)
    visit "/"
    cookies.each { |name, value| set_browser_cookie(name, value) }
    visit index_path
    expect(page).to have_selector(".sidebar-resize-handle", visible: :all)
    expect(page.evaluate_script("document.querySelector('.sidebar-resize-handle').hidden")).to be(false)
  end

  def mouse = page.driver.browser.mouse

  def handle_center_x
    page.evaluate_script(
      "(function () { const r = document.querySelector('.sidebar-resize-handle').getBoundingClientRect(); return r.left + r.width / 2; })()"
    ).round
  end

  def sidebar_width
    page.evaluate_script(
      "document.querySelector('#main-sidebar .avo-sidebar').getBoundingClientRect().width"
    )
  end

  def main_padding
    page.evaluate_script(
      "parseFloat(getComputedStyle(document.querySelector('.main[data-controller~=\"sidebar\"]')).paddingInlineStart)"
    )
  end

  def resizing?
    page.evaluate_script("document.documentElement.hasAttribute('data-sidebar-resizing')")
  end

  def at_bound
    page.evaluate_script("document.querySelector('.sidebar-resize-handle').dataset.atBound || null")
  end

  def width_cookie
    page.evaluate_script(<<~JS)
      (document.cookie.split('; ').find(function (c) { return c.startsWith('avo.sidebar.width='); }) || '')
        .split('=')[1] || null
    JS
  end

  def stored_property
    page.evaluate_script(
      "document.documentElement.style.getPropertyValue('--sidebar-width-stored')"
    )
  end

  # Press, travel, release. `during:` runs while the button is still down, which
  # is the only moment the drag-state assertions are observable.
  def drag_by(dx, y: 400, release: true, during: nil)
    x = handle_center_x
    mouse.move(x: x, y: y)
    mouse.down
    mouse.move(x: (x + dx).round, y: y, steps: 10)
    sleep 0.12 # let the rAF-coalesced write land
    during&.call
    mouse.up if release
    sleep 0.12
  end

  # Happy path (R4): the edge follows the pointer 1:1 and the content offset
  # follows the edge.
  it "widens the sidebar by the drag distance and moves the content with it" do
    visit_avo

    drag_by(100)

    expect(sidebar_width).to be_within(2).of(default_width + 100)
    expect(main_padding).to be_within(2).of(sidebar_width)
  end

  it "narrows the sidebar when dragged back toward the sidebar" do
    visit_avo(cookies: {"avo.sidebar.width" => "400"})

    drag_by(-80)

    expect(sidebar_width).to be_within(2).of(320)
  end

  # R10: pinning, plus the at-bound cue. Without the cue the pointer keeps
  # travelling while the edge stays still with no feedback in any modality.
  it "pins at the maximum and flags it" do
    visit_avo

    drag_by(900, during: -> { expect(at_bound).to eq("max") })

    expect(sidebar_width).to be_within(2).of(480)
  end

  it "pins at the minimum and flags it" do
    visit_avo

    drag_by(-900, during: -> { expect(at_bound).to eq("min") })

    expect(sidebar_width).to be_within(2).of(200)
  end

  # R4: transitions are suspended for the drag, and the release must not animate
  # the width back from the pre-drag value — that snap is a sequencing bug (write
  # the final value and flush BEFORE dropping the attribute).
  it "suspends layout transitions during the drag and restores them after" do
    visit_avo

    drag_by(120, during: lambda {
      expect(resizing?).to be(true)
      expect(
        page.evaluate_script("getComputedStyle(document.querySelector('.main')).transitionProperty")
      ).to eq("none")
    })

    expect(resizing?).to be(false)
    expect(sidebar_width).to be_within(2).of(default_width + 120)
  end

  # R5: dragging across content must not select any of it.
  it "suppresses text selection while dragging" do
    visit_avo

    drag_by(400, during: -> { expect(page.evaluate_script("getSelection().toString()")).to eq("") })

    expect(page.evaluate_script("getSelection().toString()")).to eq("")
  end

  # The Armed state. A click in the strip must leave NO trace at any point, not
  # merely none afterwards — hence the MutationObserver rather than an after-the-
  # fact check.
  it "never enters the resizing state for a press below the drag threshold" do
    visit_avo

    page.execute_script(<<~JS)
      window.__sawResizing = false;
      new MutationObserver(function () {
        if (document.documentElement.hasAttribute('data-sidebar-resizing')) window.__sawResizing = true;
      }).observe(document.documentElement, { attributes: true, attributeFilter: ['data-sidebar-resizing'] });
    JS

    drag_by(2)

    expect(page.evaluate_script("window.__sawResizing")).to be(false)
    expect(sidebar_width).to be_within(1).of(default_width)
    expect(width_cookie).to be_nil
  end

  # R13/R14: the width survives a navigation, through the cookie and the
  # server-side pre-paint carrier.
  it "persists the dragged width across a navigation" do
    visit_avo

    drag_by(100)
    expect(width_cookie).to eq("356")

    visit "/admin/resources/users/#{user.slug}"

    expect(sidebar_width).to be_within(2).of(356)
  end

  # Remove-when-default at every write site: a drag that lands on exactly the
  # default must clear the cookie, not write "256". A stored "256" would be
  # indistinguishable from a deliberate preference and would survive any future
  # change to the product default.
  it "removes the cookie when a drag lands on the default width" do
    visit_avo(cookies: {"avo.sidebar.width" => "400"})
    expect(width_cookie).to eq("400")

    drag_by(default_width - sidebar_width)

    expect(sidebar_width).to be_within(2).of(default_width)
    expect(width_cookie).to be_nil
  end

  # R6: double-click resets. It must clear BOTH the cookie and the inline
  # property — writing 256px back would leave a stored preference behind.
  it "resets to the default on double-click" do
    visit_avo

    drag_by(150)
    expect(width_cookie).to be_present

    page.execute_script(
      "document.querySelector('.sidebar-resize-handle').dispatchEvent(new MouseEvent('dblclick', { bubbles: true, cancelable: true }))"
    )
    sleep 0.3 # the reset animates the 0.1s width transition back

    expect(sidebar_width).to be_within(2).of(default_width)
    expect(width_cookie).to be_nil
    expect(stored_property).to eq("")
  end

  # A8: Escape is the ONLY revert path — every other termination commits (R7).
  it "reverts to the pointerdown width on Escape and writes nothing" do
    visit_avo

    drag_by(150, release: false, during: lambda {
      page.execute_script("document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))")
    })
    mouse.up
    sleep 0.12

    expect(sidebar_width).to be_within(2).of(default_width)
    expect(width_cookie).to be_nil
    expect(resizing?).to be(false)
  end

  # R7: a termination that is not Escape commits the last valid width.
  it "commits the last valid width when the pointer is cancelled mid-drag" do
    visit_avo

    drag_by(120, release: false)
    page.execute_script(
      "window.dispatchEvent(new PointerEvent('pointercancel', { pointerId: 1, bubbles: true }))"
    )
    sleep 0.12

    expect(sidebar_width).to be_within(2).of(default_width + 120)
    expect(width_cookie).to eq("376")
    expect(resizing?).to be(false)
  end

  # R22: in RTL the sidebar sits at the right edge, so dragging LEFT (toward the
  # content) widens it. Getting this sign wrong is easy — the prior-art formula
  # targeted a sidebar on the opposite edge and is inverted for this one.
  it "inverts the drag direction in RTL" do
    visit_avo
    page.execute_script("document.documentElement.dir = 'rtl'")

    drag_by(-100)

    expect(sidebar_width).to be_within(2).of(default_width + 100)
  end

  # R11 baseline: with the viewport clamp active, the stored value (480) and the
  # rendered width (40vw = 448 here) differ. A stored-value baseline would
  # compute 480 - 20 = 460, re-clamp it straight back to 448 and move nothing —
  # a 32px dead zone with the edge detached from the cursor. Narrowing is what
  # discriminates: widening is pinned at the max either way.
  it "starts the drag from the rendered width, not the stored one" do
    visit_avo(width: 1120, height: 900, cookies: {"avo.sidebar.width" => "480"})

    rendered = sidebar_width
    expect(rendered).to be < 480 # guard: the viewport clamp really is engaged

    drag_by(-20)

    expect(sidebar_width).to be_within(3).of(rendered - 20)
  end
end
