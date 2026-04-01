require "rails_helper"

RSpec.describe AlertComponentPreview, type: :component do
  it "renders the default preview" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".alert", count: 6)
    expect(page).to have_css(".alert--default")
    expect(page).to have_css(".alert--success", count: 2)
    expect(page).to have_css(".alert--info")
    expect(page).to have_css(".alert--warning")
    expect(page).to have_css(".alert--danger")
    expect(page).to have_text("Flash-compatible single line")
  end
end
