require "rails_helper"

RSpec.describe Avo::HotkeyComponent, type: :component do
  it "renders the keyboard shortcuts modal content" do
    render_inline(described_class.new)

    expect(page).to have_css(".hotkey", visible: :all)
    expect(page).to have_text("Keyboard shortcuts")
    expect(page).to have_text("Navigation")
    expect(page).to have_text("Records")
    expect(page).to have_css("[aria-label='Up arrow or down arrow']", visible: :all)
    expect(page).to have_text("⌘")
    expect(page).to have_text("CTRL")
  end
end
