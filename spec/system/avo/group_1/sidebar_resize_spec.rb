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
