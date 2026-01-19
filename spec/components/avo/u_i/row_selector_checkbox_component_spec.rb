require "rails_helper"

RSpec.describe Avo::UI::RowSelectorCheckboxComponent, type: :component do
  it "renders a checkbox configured for item-selector controller" do
    render_inline(described_class.new(index: 3))

    expected_label = I18n.t("avo.select_item")

    expect(page).to have_css("label.checkbox.mx-3")
    expect(page).to have_css("input.checkbox__input[type='checkbox'][name='#{expected_label}'][title='#{expected_label}']")
    expect(page).to have_css("input.checkbox__input[data-index='3']")
    expect(page).to have_css("input.checkbox__input[data-action*='input->item-selector#toggle']")
    expect(page).to have_css("input.checkbox__input[data-action*='input->item-select-all#selectRow']")
    expect(page).to have_css("input.checkbox__input[data-item-select-all-target='itemCheckbox']")
    expect(page).to have_css("input.checkbox__input[data-tippy='tooltip']")
  end

  it "supports checked and disabled states" do
    render_inline(described_class.new(index: 1, checked: true, disabled: true))

    expect(page).to have_css("input.checkbox__input[checked][disabled]")
    expect(page).to have_css(".checkbox--disabled")
  end

  context "when avo-pro is installed" do
    it "adds record-selector action" do
      allow(Avo.plugin_manager).to receive(:installed?).with("avo-pro").and_return(true)

      render_inline(described_class.new(index: 1))

      expect(page).to have_css("input.checkbox__input[data-action*='click->record-selector#toggleMultiple']")
    end
  end
end
