require "rails_helper"

RSpec.describe "Festivity decorations toggle", type: :system do
  let(:hide_toggle) { ".color-scheme-switcher--inline [data-festivity-decorations='off']" }
  let(:show_toggle) { ".color-scheme-switcher--inline [data-festivity-decorations='on']" }

  around do |example|
    original = Avo.configuration.instance_variable_get(:@festivity)
    Avo.configuration.festivity = :christmas
    example.run
  ensure
    Avo.configuration.festivity = original
  end

  # Marks the page so a reload (which would wipe it) is detectable.
  def mark_page
    page.execute_script("window.festivitySpecMarker = true")
  end

  def same_page?
    page.evaluate_script("window.festivitySpecMarker === true")
  end

  context "with cookie persistence" do
    before { allow(Avo.configuration.appearance).to receive(:persistence).and_return(:cookie) }

    it "turns the decorations off and back on without a reload, and remembers the choice" do
      visit "/admin/resources/projects"
      expect(page).to have_css("html.festivity-christmas")
      mark_page

      find(hide_toggle).click
      expect(page).to have_no_css("html.festivity-christmas")
      expect(same_page?).to be true
      expect(page.driver.cookies["festivity_christmas"]&.value).to eq("off")

      visit "/admin/resources/projects"
      expect(page).to have_no_css("html.festivity-christmas")
      mark_page

      find(show_toggle).click
      expect(page).to have_css("html.festivity-christmas")
      expect(same_page?).to be true

      visit "/admin/resources/projects"
      expect(page).to have_css("html.festivity-christmas")
    end
  end

  context "with database persistence" do
    it "saves the opt-out to the user's settings" do
      visit "/admin/resources/projects"
      expect(page).to have_css("html.festivity-christmas")

      find(hide_toggle).click
      expect(page).to have_no_css("html.festivity-christmas")

      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep 0.05 until admin.reload.avo_preferences&.dig("appearance", "festivity_christmas") == "off"
      end

      visit "/admin/resources/projects"
      expect(page).to have_no_css("html.festivity-christmas")
    end
  end

  context "when :festivity is locked" do
    before { allow(Avo.configuration.appearance).to receive(:festivity_locked?).and_return(true) }

    it "does not render the toggle" do
      visit "/admin/resources/projects"

      expect(page).to have_css("html.festivity-christmas")
      expect(page).to have_no_css("[data-festivity-decorations]", visible: :all)
    end
  end

  describe "the Christmas look" do
    # Resolves any CSS color (oklch, color-mix, ...) to sRGB through a canvas
    # and returns the WCAG contrast ratio between an element's text and fill.
    def contrast_of(selector)
      page.evaluate_script(<<~JS)
        (() => {
          const ctx = document.createElement("canvas").getContext("2d", {willReadFrequently: true})
          const rgb = (color) => {
            ctx.clearRect(0, 0, 1, 1)
            ctx.fillStyle = color
            ctx.fillRect(0, 0, 1, 1)
            return Array.from(ctx.getImageData(0, 0, 1, 1).data.slice(0, 3))
          }
          const luminance = (c) => {
            const [r, g, b] = c.map((v) => {
              v /= 255
              return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4
            })
            return 0.2126 * r + 0.7152 * g + 0.0722 * b
          }
          const style = getComputedStyle(document.querySelector(#{selector.to_json}))
          const [a, b] = [luminance(rgb(style.color)), luminance(rgb(style.backgroundColor))]
          return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05)
        })()
      JS
    end

    def add_badges
      page.execute_script(<<~JS)
        document.body.insertAdjacentHTML("beforeend",
          '<span id="subtle-neutral" class="badge badge--subtle badge--neutral">Subtle</span>' +
          '<span id="solid-neutral" class="badge badge--solid badge--neutral">Solid</span>')
      JS
    end

    # The computed color of `value` resolved inside `selector`.
    def resolved_color(selector, value)
      page.evaluate_script(<<~JS)
        (() => {
          const probe = document.createElement("span")
          probe.style.color = #{value.to_json}
          document.querySelector(#{selector.to_json}).appendChild(probe)
          const color = getComputedStyle(probe).color
          probe.remove()
          return color
        })()
      JS
    end

    %w[light dark].each do |scheme|
      it "keeps neutral badges readable, solid ones included, in #{scheme} mode" do
        visit "/admin/resources/projects"
        page.execute_script("document.documentElement.classList.toggle('dark', #{scheme == "dark"})")
        add_badges

        expect(contrast_of("#subtle-neutral")).to be >= 4.5
        expect(contrast_of("#solid-neutral")).to be >= 3
      end
    end

    it "colors the navbar text from the Evergreen ramp over the user's neutral pick" do
      visit "/admin/resources/projects"
      page.execute_script("document.documentElement.classList.add('neutral-theme-slate')")

      expect(resolved_color(".top-navbar", "var(--top-navbar-content)"))
        .to eq(resolved_color("body", "var(--color-avo-neutral-300)"))
    end
  end
end
