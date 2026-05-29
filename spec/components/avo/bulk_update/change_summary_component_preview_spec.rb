require "rails_helper"

RSpec.describe BulkUpdateChangeSummaryComponentPreview, type: :component do
  it "renders the default preview (hidden, aria-live region)" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".bulk-update-change-summary", visible: :all)
  end

  it "renders the one_dirty_field preview (simulated populated state)" do
    render_preview(:one_dirty_field, from: described_class)

    expect(page).to have_text("Set")
    expect(page).to have_text("stage")
  end

  it "renders the many_dirty_fields_truncated preview with the overflow line" do
    render_preview(:many_dirty_fields_truncated, from: described_class)

    expect(page).to have_text("more fields")
  end
end
