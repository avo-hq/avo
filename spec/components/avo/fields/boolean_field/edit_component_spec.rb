require "rails_helper"

RSpec.describe Avo::Fields::BooleanField::EditComponent, type: :component do
  let(:record) { User.new(first_name: "Jane", last_name: "Doe", email: "jane@example.com", active: true) }
  let(:resource) { Avo::Resources::User.new(record:, view: :edit) }
  let(:form) { ActionView::Helpers::FormBuilder.new(:user, record, vc_test_controller.view_context, {}) }

  def build_field(view: :edit)
    Avo::Fields::BooleanField.new(:active, name: "Is admin")
      .hydrate(record:, resource:, view: Avo::ViewInquirer.new(view.to_s))
  end

  def render_component(view: :edit)
    field = build_field(view: view)
    component = described_class.new(field:, resource:, form:, view: Avo::ViewInquirer.new(view.to_s))
    render_inline(component)
  end

  context "default :edit view" do
    it "renders a single checkbox preserving record value" do
      render_component(view: :edit)
      expect(page).to have_css("input[type='checkbox'][name='user[active]']")
      expect(page).not_to have_css("input[type='radio']")
    end

    it "does not wire the bulk-update-field controller" do
      render_component(view: :edit)
      expect(page).not_to have_css("[data-controller~='bulk-update-field']")
    end
  end

  context "when view is :bulk_edit" do
    it "renders a tri-state radio group (Unchanged / True / False)" do
      render_component(view: :bulk_edit)

      expect(page).to have_css("input[type='radio'][name='user[active]']", count: 3)
      expect(page).to have_css("[role='radiogroup']")
      expect(page).not_to have_css("input[type='checkbox'][name='user[active]']")
    end

    it "defaults to Unchanged checked, with True and False unchecked" do
      render_component(view: :bulk_edit)

      unchanged = page.find("input[type='radio'][name='user[active]'][value='#{Avo::Fields::BooleanField::EditComponent::BULK_EDIT_UNCHANGED}']")
      true_radio = page.find("input[type='radio'][name='user[active]'][value='true']")
      false_radio = page.find("input[type='radio'][name='user[active]'][value='false']")

      expect(unchanged["checked"]).to eq "checked"
      expect(true_radio["checked"]).to be_nil
      expect(false_radio["checked"]).to be_nil
    end

    it "localizes the three radio labels" do
      render_component(view: :bulk_edit)

      expect(page).to have_text(I18n.t("avo.bulk_update.boolean.unchanged"))
      expect(page).to have_text(I18n.t("avo.bulk_update.boolean.true"))
      expect(page).to have_text(I18n.t("avo.bulk_update.boolean.false"))
    end

    it "wires the bulk-update-field Stimulus controller on the wrapper" do
      render_component(view: :bulk_edit)
      expect(page).to have_css("[data-controller~='bulk-update-field']")
      expect(page).to have_css("[data-bulk-update-field-key-value='active']")
    end
  end
end
