require "rails_helper"

RSpec.describe EmptyStateComponentPreview, type: :component do
  it "renders the default preview" do
    render_preview(:default, from: described_class, params: {
      message: "No record found"
    })

    expect(page).to have_css(".state")
    expect(page).to have_text("No record found")
    expect(page).to have_css(".state__illustration")
  end
end
