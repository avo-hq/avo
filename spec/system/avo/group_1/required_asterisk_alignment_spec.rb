require "rails_helper"

# AVO-1731: on a validation error Rails' field_error_proc wraps the label in a block-level
# div.field_with_errors, which pushed the required asterisk onto its own line.
RSpec.describe "required asterisk alignment", type: :system do
  it "keeps the asterisk on the label's line when the field has a validation error" do
    visit avo.new_resources_project_path

    fill_in "project_name", with: ""
    save

    expect(page).to have_text "Name can't be blank"

    label, asterisk = page.evaluate_script(<<~JS)
      (() => {
        const wrapper = document.querySelector('[data-field-id="name"] .field-wrapper__label')
        const rect = (el) => { const r = el.getBoundingClientRect(); return {top: r.top, bottom: r.bottom} }
        return [rect(wrapper.querySelector('label')), rect(wrapper.querySelector('.text-danger-content'))]
      })()
    JS

    expect(asterisk["top"]).to be < label["bottom"]
    expect(asterisk["bottom"]).to be > label["top"]
  end
end
