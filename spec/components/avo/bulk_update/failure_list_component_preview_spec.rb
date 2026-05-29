require "rails_helper"

RSpec.describe BulkUpdateFailureListComponentPreview, type: :component do
  it "renders the default preview with mixed reasons" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".bulk-update-failure-list[role='alert']")
    expect(page).to have_text(/Not allowed/i)
    expect(page).to have_text(/Validation failed/i)
    expect(page).to have_text(/Record changed elsewhere/i)
  end

  it "renders the empty preview without crashing" do
    render_preview(:empty, from: described_class)

    expect(page).to have_css(".bulk-update-failure-list")
  end

  it "renders the one_validation preview with truncation" do
    render_preview(:one_validation, from: described_class)

    expect(page).to have_text(/Validation failed/i)
  end

  it "renders the mixed_reasons preview" do
    render_preview(:mixed_reasons, from: described_class)

    # 4 distinct failure rows in the mixed-reasons preview.
    expect(page).to have_css(".bulk-update-failure-list__item", count: 4)
  end

  it "renders the with_custom_reason preview using the humanized fallback" do
    render_preview(:with_custom_reason, from: described_class)

    expect(page).to have_text(/Custom business rule/i)
  end
end
