require "rails_helper"

RSpec.describe Avo::KeyboardShortcutsComponent, type: :component do
  it "renders the keyboard shortcuts modal" do
    render_inline(described_class.new)

    expect(page).to have_css(".hotkey", visible: :all)
    expect(page).to have_text("Keyboard shortcuts")
    expect(page).to have_text("Navigation")
    expect(page).to have_text("Edit view")
    expect(page).to have_css("[aria-label='Up arrow or down arrow']", visible: :all)
    expect(page).to have_text("⌘")
    expect(page).to have_text("CTRL")
  end

  # Plugin shortcuts come from the plugin's registration, so the modal never advertises a key nothing listens for.
  it "lists a plugin shortcut only when the plugin registered it" do
    render_inline(described_class.new)
    expect(page).not_to have_text("Open the assistant")

    plugin = Avo::Plugin.new(name: "avo-ai", priority: 10)
      .register_hotkey(:toggle_assistant, default: "Mod+j", label: "Open the assistant", section: "Navigation")
    allow(Avo.plugin_manager).to receive(:plugins).and_return([plugin])

    render_inline(described_class.new)
    expect(page).to have_css(".hotkey__row", text: "Open the assistant")
  end

  it "shows the overridden key and drops disabled shortcuts" do
    original = Avo.configuration.hotkeys
    Avo.configuration.hotkeys = {bindings: {"record.edit": "Shift+E", "record.delete": false}}

    render_inline(described_class.new)

    expect(page).to have_css(".hotkey__row", text: /Edit record\s*Shift\s*\+\s*E/)
    expect(page).not_to have_text("Delete record")
  ensure
    Avo.configuration.hotkeys = original
  end
end
