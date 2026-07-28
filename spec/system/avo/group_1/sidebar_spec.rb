require "rails_helper"

RSpec.describe "sidebar", type: :system do
  let!(:user) { create :user }
  let(:sidebar_toggle_selector) { "button[data-action='click->sidebar#toggleSidebarForViewport']" }

  context "desktop" do
    before(:example) do
      Capybara.reset_sessions!
      visit "/"
    end

    it "is open on login" do
      expect(page).to have_selector "div.sidebar-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find(sidebar_toggle_selector)
      expect(page).to have_selector "div.sidebar-open"
      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-open"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-open"
    end

    it "remembers user choice" do
      sidebar_button = page.find(sidebar_toggle_selector)
      sidebar_button.click

      visit "/admin/resources/users"

      expect(page).to_not have_selector "div.sidebar-open"
    end
  end

  context "mobile" do
    before(:example) do
      Capybara.reset_sessions!
      Capybara.current_session.current_window.resize_to(428, 926)
      visit "/"
    end

    it "is closed on login" do
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end

    it "toggles between open and closed" do
      sidebar_button = page.find(sidebar_toggle_selector)
      expect(page).to_not have_selector "div.sidebar-mobile-open"

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-mobile-open"

      sidebar_button.click
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end

    it "remains closed on navigation" do
      expect(page).to_not have_selector "div.sidebar-mobile-open"

      visit "/admin/resources/posts"
      expect(page).to_not have_selector "div.sidebar-mobile-open"
    end
  end

  context "when sidebar[:toggle_visible] is false" do
    around do |example|
      original = Avo.configuration.sidebar
      Avo.configuration.sidebar = original.merge(toggle_visible: false)
      example.run
      Avo.configuration.sidebar = original
    end

    it "hides the desktop toggle but keeps mobile access" do
      Capybara.reset_sessions!
      Capybara.current_session.current_window.resize_to(1280, 800)
      visit "/"

      expect(page).to_not have_selector(sidebar_toggle_selector, visible: true)

      Capybara.current_session.current_window.resize_to(428, 926)
      sidebar_button = page.find(sidebar_toggle_selector, visible: true)

      sidebar_button.click
      expect(page).to have_selector "div.sidebar-mobile-open"
    end
  end

  # Unit 4 / R12: sidebar navigation labels render on a single line and truncate
  # with an ellipsis when they overflow, with the full text available on hover
  # via a `title` attribute. See docs/plans/2026-07-24-001-feat-resizable-sidebar-plan.md.
  context "label ellipsis (R12)" do
    # A multi-word label wider than the 256px sidebar. Real words with spaces so
    # that, without truncation, it would wrap onto several lines — which is what
    # the height assertions detect.
    let(:long_label) { "Extraordinarily Long Navigation Label That Overflows The Sidebar Width" }

    before(:example) do
      # `navigation_label` (a class method) defaults to the resource's plural
      # name; override just the Users resource so we have one deliberately long
      # label next to the other (short) resource labels.
      allow(Avo::Resources::User)
        .to receive(:navigation_label).and_return(long_label)

      Capybara.reset_sessions!
      visit "/"
    end

    # The visible (desktop) `#main-sidebar` copy of the labels. The mobile
    # sidebar is a separate, hidden render, so scoping to `#main-sidebar` keeps
    # `offsetHeight`/`scrollWidth` measurements on the on-screen element.
    def desktop_labels
      all("#main-sidebar .sidebar-link__label")
    end

    it "renders a long label on one line, truncated, with the full text in `title`" do
      long = find("#main-sidebar .sidebar-link__label", text: long_label)
      short = desktop_labels.reject { |node| node.text == long_label }.min_by { |node| node.text.length }

      # One line: the long label is exactly as tall as a short sibling. A wrapped
      # label would be two or three times taller.
      expect(long.evaluate_script("this.offsetHeight"))
        .to eq(short.evaluate_script("this.offsetHeight"))

      # Truncated: the intrinsic content is wider than the rendered box.
      expect(long.evaluate_script("this.scrollWidth"))
        .to be > long.evaluate_script("this.clientWidth")

      # Full text stays available on hover.
      expect(long[:title]).to eq(long_label)
    end

    it "leaves a short label unaltered — no truncation, full text in `title`" do
      short = desktop_labels.reject { |node| node.text == long_label }.min_by { |node| node.text.length }

      # Not truncated: content fits within the box (allow 1px for rounding).
      expect(short.evaluate_script("this.scrollWidth"))
        .to be <= (short.evaluate_script("this.clientWidth") + 1)

      # The `title` mirrors the label verbatim.
      expect(short[:title]).to eq(short.text)
    end

    it "keeps the hotkey badge fully visible beside a truncated label" do
      # The Users resource carries a hotkey ("r u"), so its (now long) link
      # renders a badge. With `flex-1 min-w-0` on the label and `shrink-0` on the
      # badge, the badge must stay intact and within the link's box rather than
      # being squashed or pushed past the sidebar edge.
      result = page.evaluate_script(<<~JS)
        (function () {
          var links = document.querySelectorAll('#main-sidebar .sidebar-link');
          var link = null;
          for (var i = 0; i < links.length; i++) {
            var lbl = links[i].querySelector('.sidebar-link__label');
            if (lbl && lbl.getAttribute('title') === #{long_label.to_json}) { link = links[i]; break; }
          }
          if (!link) return 'no-link';
          var badge = link.querySelector('.hotkey-badge');
          if (!badge) return 'no-badge';
          var lr = link.getBoundingClientRect();
          var br = badge.getBoundingClientRect();
          if (br.width <= 0) return 'no-width';
          return (br.right <= lr.right + 1 && br.left >= lr.left) ? true : 'clipped';
        })()
      JS

      expect(result).to eq(true)
    end

    it "does not introduce horizontal overflow in the sidebar body" do
      overflow = page.evaluate_script(<<~JS)
        (function () {
          var el = document.querySelector('#main-sidebar .sidebar__body-content');
          return el.scrollWidth - el.clientWidth;
        })()
      JS

      expect(overflow).to be <= 1
    end

    it "keeps the active item within the sidebar body viewport on load" do
      visit "/admin/resources/users"

      in_view = page.evaluate_script(<<~JS)
        (function () {
          var el = document.querySelector('#main-sidebar .sidebar-link.active');
          if (!el) return null;
          var body = el.closest('.sidebar__body');
          var e = el.getBoundingClientRect();
          var b = body.getBoundingClientRect();
          return e.top >= b.top - 2 && e.bottom <= b.bottom + 2;
        })()
      JS

      expect(in_view).to eq(true)
    end
  end

  # Unit 4 / A10: R12 extends to section headings, which must not wrap at the
  # new minimum width either.
  context "section heading ellipsis (A10)" do
    let(:long_heading) { "Extremely Long Section Heading That Would Otherwise Wrap Onto Two Lines" }

    around do |example|
      # Make the "Resources" section heading long. `reload!` restores the
      # file-backed translations afterwards.
      I18n.backend.store_translations(:en, avo: {resources: long_heading})
      example.run
    ensure
      I18n.backend.reload!
    end

    before(:example) do
      Capybara.reset_sessions!
      visit "/"
    end

    it "renders a long section heading on one line, truncated, with `title`" do
      title = find("#main-sidebar .sidebar-section__title", text: long_heading)

      # Single line: `leading-6` is ~24px, so a wrapped two-line heading (~48px)
      # would blow past this bound.
      expect(title.evaluate_script("this.offsetHeight")).to be < 40

      # Truncated: content wider than the rendered box.
      expect(title.evaluate_script("this.scrollWidth"))
        .to be > title.evaluate_script("this.clientWidth")

      expect(title[:title]).to eq(long_heading)
    end
  end
end
