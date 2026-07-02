# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::Fields::CheckboxListField::EditComponent, type: :component do
  around do |example|
    I18n.with_locale(:ar) { example.run }
  end

  let(:record) { Team.new(name: "Avo") }
  let(:resource) { Avo::Resources::Team.new(record:, view: :edit) }
  let(:form) { ActionView::Helpers::FormBuilder.new(:team, record, vc_test_controller.view_context, {}) }
  let(:options) { [{id: 1, title: "Alpha"}, {id: 2, title: "Beta"}] }

  def build_field
    field = Avo::Fields::CheckboxListField.new(:team_member_ids, name: "Team members", options:, inline_search: true)
      .hydrate(record:, resource:, view: :edit)
    allow(field).to receive(:value).and_return([])
    field
  end

  it "stores the plural template with a count placeholder for client-side substitution" do
    component = Avo::Fields::CheckboxListField::EditComponent.new(field: build_field, resource:, form:)
    render_inline(component)

    wrapper = page.find("[data-controller='checkbox-list-field']")
    other_template = wrapper["data-checkbox-list-field-hidden-selections-other-value"]

    expect(other_template).to eq(I18n.t("avo.checkbox_list.hidden_selections.other"))
    expect(other_template).to include("%{count}")
  end

  it "does not bake in the zero plural form, which lacks a count placeholder" do
    zero_form = I18n.t("avo.checkbox_list.hidden_selections", count: "%{count}".to_i)

    expect(zero_form).not_to include("%{count}")

    component = Avo::Fields::CheckboxListField::EditComponent.new(field: build_field, resource:, form:)
    render_inline(component)

    other_template = page.find("[data-controller='checkbox-list-field']")["data-checkbox-list-field-hidden-selections-other-value"]

    expect(other_template).to include("%{count}")
    expect(other_template).not_to eq(zero_form)
  end
end
