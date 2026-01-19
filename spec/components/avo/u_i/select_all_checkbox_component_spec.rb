require "rails_helper"

RSpec.describe Avo::UI::SelectAllCheckboxComponent, type: :component do
  it "renders a checkbox configured for item-select-all controller" do
    render_inline(described_class.new)

    expected_label = I18n.t("avo.select_all")

    expect(page).to have_css("input.checkbox__input[type='checkbox'][name='#{expected_label}'][title='#{expected_label}']")
    expect(page).to have_css("input.checkbox__input[data-action='input->item-select-all#toggle']")
    expect(page).to have_css("input.checkbox__input[data-item-select-all-target='checkbox']")
    expect(page).to have_css("input.checkbox__input[data-tippy='tooltip']")
  end

  it "passes through state props and merges data" do
    render_inline(described_class.new(
      checked: true,
      disabled: true,
      data: {foo: "bar"}
    ))

    expect(page).to have_css("input.checkbox__input[checked][disabled][data-foo='bar']")
  end

  it "supports indeterminate state" do
    render_inline(described_class.new(indeterminate: true))

    expect(page).to have_css(".checkbox--indeterminate")
    expect(page).to have_css("input.checkbox__input[data-indeterminate='true'][aria-checked='mixed']")
  end
end
