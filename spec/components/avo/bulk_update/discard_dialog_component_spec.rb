require "rails_helper"

RSpec.describe Avo::BulkUpdate::DiscardDialogComponent, type: :component do
  it "renders role='alertdialog' so SRs announce it assertively" do
    render_inline(described_class.new)

    expect(page).to have_css(".bulk-update-discard-dialog[role='alertdialog']", visible: :all)
  end

  it "is initially hidden so the form Stimulus controller can toggle it on Esc/X/backdrop" do
    render_inline(described_class.new)

    expect(page.first(".bulk-update-discard-dialog", visible: :all)["hidden"]).to be_truthy
  end

  it "uses the alert-octagon icon to signal a destructive action" do
    render_inline(described_class.new)

    expect(page).to have_css(".bulk-update-discard-dialog__icon svg", visible: :all)
  end

  it "renders both buttons (Discard changes, Keep editing) with localized copy" do
    render_inline(described_class.new)

    expect(page).to have_button("Discard changes", visible: :all)
    expect(page).to have_button("Keep editing", visible: :all)
  end

  it "wires the Discard button to the form controller's confirm action" do
    render_inline(described_class.new)

    button = page.find(".bulk-update-discard-dialog__discard", visible: :all)
    expect(button["data-action"]).to include("click->bulk-update-form#confirmDiscard")
  end

  it "wires the Keep editing button to the form controller's cancel action" do
    render_inline(described_class.new)

    button = page.find(".bulk-update-discard-dialog__keep", visible: :all)
    expect(button["data-action"]).to include("click->bulk-update-form#cancelDiscard")
  end

  it "moves focus to the Keep editing button on open (autofocus)" do
    render_inline(described_class.new)

    button = page.find(".bulk-update-discard-dialog__keep", visible: :all)
    expect(button["autofocus"]).to be_truthy
  end

  it "captures keydown so the form controller can implement Esc = Keep editing" do
    render_inline(described_class.new)

    container = page.find(".bulk-update-discard-dialog", visible: :all)
    expect(container["data-action"]).to include("keydown->bulk-update-form#discardDialogKeydown")
  end

  it "is keyed to the form's Stimulus controller via discardDialog target" do
    render_inline(described_class.new)

    expect(page).to have_css(
      "[data-bulk-update-form-target='discardDialog']",
      visible: :all
    )
  end

  it "labels and describes the dialog (a11y)" do
    render_inline(described_class.new)

    container = page.find(".bulk-update-discard-dialog", visible: :all)
    expect(container["aria-labelledby"]).to eq("bulk-update-discard-dialog-heading")
    expect(container["aria-describedby"]).to eq("bulk-update-discard-dialog-body")
  end
end
