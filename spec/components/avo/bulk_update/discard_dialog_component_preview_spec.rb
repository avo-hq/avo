require "rails_helper"

RSpec.describe BulkUpdateDiscardDialogComponentPreview, type: :component do
  it "renders the default preview (hidden)" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".bulk-update-discard-dialog[role='alertdialog']", visible: :all)
  end

  it "renders the open preview with both buttons" do
    render_preview(:open, from: described_class)

    expect(page).to have_button("Discard changes")
    expect(page).to have_button("Keep editing")
  end
end
