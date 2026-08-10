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

  # The assistant shortcut belongs to avo-ai, so the modal must not advertise a key
  # nothing is listening for when the gem isn't installed.
  it "lists the assistant shortcut only when avo-ai is installed" do
    render_inline(described_class.new)
    expect(page).not_to have_text("Open the assistant")

    allow(Avo.plugin_manager).to receive(:installed?).and_call_original
    allow(Avo.plugin_manager).to receive(:installed?).with("avo-ai").and_return(true)

    render_inline(described_class.new)
    expect(page).to have_text("Open the assistant")
  end

  # avo-intelligence is avo-ai's former name; an app still on one of its alphas registers the
  # old plugin name and must keep the row.
  it "lists the assistant shortcut under the former avo-intelligence gem name" do
    allow(Avo.plugin_manager).to receive(:installed?).and_call_original
    allow(Avo.plugin_manager).to receive(:installed?).with("avo-intelligence").and_return(true)

    render_inline(described_class.new)
    expect(page).to have_text("Open the assistant")
  end
end
