require "rails_helper"

RSpec.describe Avo::Concerns::FormBuilder do
  # avo-reactive_fields and ejected edit components build the form too, and none of them is the edit component.
  let(:component) do
    Class.new { include Avo::Concerns::FormBuilder }.new
  end

  around do |example|
    original = Avo.configuration.warn_on_unsaved_changes
    Avo.configuration.warn_on_unsaved_changes = true
    example.run
  ensure
    Avo.configuration.warn_on_unsaved_changes = original
  end

  it "does not warn on a form built outside of the edit component" do
    expect(component.warn_on_unsaved_changes?).to be false
    expect(component.unsaved_changes_values).to eq({})
  end
end
