require "rails_helper"

RSpec.describe "Avo::BaseComponent#hotkey_badge", type: :component do
  class HotkeyBadgeTestComponent < Avo::BaseComponent
    def initialize(hotkey:)
      @hotkey = hotkey
    end

    def call
      hotkey_badge(@hotkey)
    end
  end

  around do |example|
    original = Avo.configuration.hotkeys
    Avo.configuration.hotkeys = {enabled: true, show_key_badges: true}
    example.run
    Avo.configuration.hotkeys = original
  end

  it "renders Mod+Enter as ⌘ on mac / CTRL elsewhere and shows the return icon" do
    render_inline(HotkeyBadgeTestComponent.new(hotkey: "Mod+Enter"))

    expect(page).to have_text("⌘")
    expect(page).to have_text("CTRL")
    expect(page).to have_text("↵")

    expect(page).not_to have_text("MOD")
    expect(page).not_to have_text("ENTER")
  end

  it "renders Return as the return icon" do
    render_inline(HotkeyBadgeTestComponent.new(hotkey: "Return"))

    expect(page).to have_text("↵")
    expect(page).not_to have_text("RETURN")
  end

  context "when show_key_badges is false" do
    around do |example|
      original = Avo.configuration.hotkeys
      Avo.configuration.hotkeys = {show_key_badges: false}
      example.run
      Avo.configuration.hotkeys = original
    end

    it "renders nothing" do
      render_inline(HotkeyBadgeTestComponent.new(hotkey: "d"))

      expect(page).not_to have_css("kbd")
      expect(page).not_to have_text("D")
    end
  end

  context "when hotkeys are disabled" do
    around do |example|
      original = Avo.configuration.hotkeys
      Avo.configuration.hotkeys = {enabled: false}
      example.run
      Avo.configuration.hotkeys = original
    end

    it "renders nothing" do
      render_inline(HotkeyBadgeTestComponent.new(hotkey: "d"))

      expect(page).not_to have_css("kbd")
      expect(page).not_to have_text("D")
    end
  end
end

