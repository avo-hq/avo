require "rails_helper"

RSpec.describe SlideOverComponentPreview, type: :component do
  it "renders the default preview" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".slide-over")
    expect(page).to have_css(".slide-over__panel[role='dialog']")
    expect(page).to have_css(".slide-over__heading", text: "Bulk update - 4 records")
    expect(page).to have_css(".slide-over__footer")
  end

  it "renders the long body preview" do
    render_preview(:with_long_body, from: described_class)

    expect(page).to have_css(".slide-over--width-lg")
    expect(page).to have_text("Long body")
    expect(page).to have_css(".slide-over__footer")
  end

  it "renders the narrow viewport (bottom-sheet) preview" do
    render_preview(:narrow_viewport, from: described_class)

    expect(page).to have_css(".slide-over.slide-over--bottom-sheet")
  end

  it "renders the backdrop-click-disabled preview" do
    render_preview(:with_backdrop_click_disabled, from: described_class)

    expect(page).to have_css(".slide-over[data-slide-over-close-modal-on-backdrop-click-value='false']")
  end
end
