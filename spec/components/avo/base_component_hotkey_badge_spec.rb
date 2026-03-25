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
end

