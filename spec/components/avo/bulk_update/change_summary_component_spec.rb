require "rails_helper"

RSpec.describe Avo::BulkUpdate::ChangeSummaryComponent, type: :component do
  it "renders an empty aria-live=polite region keyed to the form's Stimulus controller" do
    render_inline(described_class.new(records_count: 47))

    expect(page).to have_css(".bulk-update-change-summary[aria-live='polite']", visible: :all)
    expect(page).to have_css(
      "[data-bulk-update-form-target='changeSummary'][data-records-count='47']",
      visible: :all
    )
  end

  it "starts hidden so it only appears once a dirty key fires (R8)" do
    render_inline(described_class.new(records_count: 5))

    # The static markup has the `hidden` attribute on the region; the form
    # Stimulus controller drops it when the first dirty key arrives.
    expect(page.first(".bulk-update-change-summary", visible: :all)["hidden"]).to be_truthy
  end

  it "renders the list-check icon (neutral background, accent border-start)" do
    render_inline(described_class.new(records_count: 5))

    expect(page).to have_css(".bulk-update-change-summary__icon svg", visible: :all)
  end

  it "exposes the placeholder copy that the Stimulus controller swaps in" do
    render_inline(described_class.new(records_count: 5))

    expect(page).to have_css("[data-bulk-update-form-target='changeSummaryTitle']", visible: :all)
  end

  it "exposes an overflow region for the 'and N more fields' truncation case" do
    render_inline(described_class.new(records_count: 5))

    expect(page).to have_css(
      "[data-bulk-update-form-target='changeSummaryOverflow'][hidden]",
      visible: :all
    )
  end
end
