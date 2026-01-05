require "rails_helper"

RSpec.describe Avo::Fields::Common::BooleanCheckComponent, type: :component do
  it "outputs an accessible text" do
    I18n.backend.store_translations(:en, true: "Yes", false: "No", "indeterminate": "Indeterminate")

    render_inline(described_class.new(checked: true))
    expect(page.text.strip).to eql("Yes")

    render_inline(described_class.new(checked: false))
    expect(page.text.strip).to eql("No")

    render_inline(described_class.new(checked: nil))
    expect(page.text.strip).to eql("Indeterminate")
  end
end
