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
end
