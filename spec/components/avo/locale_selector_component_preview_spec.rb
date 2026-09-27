require "rails_helper"

RSpec.describe LocaleSelectorComponentPreview, type: :component do
  it "renders the default preview" do
    render_preview(:default, from: described_class)

    expect(page).to have_css(".locale-selector", count: 2)
    expect(page).to have_css(".locale-selector__item", text: "العربية", visible: :all)
  end
end
