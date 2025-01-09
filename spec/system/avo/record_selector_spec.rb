require "rails_helper"

RSpec.feature "RecordSelectors", type: :system do
  let!(:projects) { create_list :project, 5 }

  it "hold shift and select" do
    visit avo.resources_projects_path

    all_checkboxes = all(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow click->record-selector#toggleMultiple"]')

    select_all_checkbox = find(:css, 'input[type="checkbox"][data-action="input->item-select-all#toggle"]')

    expect(indeterminate?(select_all_checkbox)).to be false

    # Click the first checkbox
    all_checkboxes.first.click

    expect(indeterminate?(select_all_checkbox)).to be true

    # Hold shift and click the last checkbox
    all_checkboxes.last.click(:shift)

    # Validate that all checkboxes are selected
    expect(all_checkboxes.count(&:checked?)).to be == projects.count

    # Click second checkbox
    all_checkboxes[1].click

    # Hold shift and click the last checkbox
    all_checkboxes.last.click(:shift)

    # Validate that only first checkbox is selected
    expect(all_checkboxes.count(&:checked?)).to be == 1
    expect(all_checkboxes.first.checked?).to be true

    all_checkboxes.first.click
    expect(indeterminate?(select_all_checkbox)).to be false
  end

  def indeterminate?(checkbox)
    page.evaluate_script("arguments[0].indeterminate", checkbox.native)
  end
end
