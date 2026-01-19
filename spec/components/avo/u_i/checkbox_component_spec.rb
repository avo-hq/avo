require "rails_helper"

RSpec.describe Avo::UI::CheckboxComponent, type: :component do
  describe "rendering" do
    it "renders the base structure" do
      render_inline(described_class.new)

      expect(page).to have_css("label.checkbox")
      expect(page).to have_css("input.checkbox__input[type='checkbox']")
      expect(page).to have_css(".checkbox__input-wrapper")
      expect(page).to have_css(".checkbox__box")
    end

    it "renders label and description when provided" do
      render_inline(described_class.new(label: "Label", description: "Description"))

      expect(page).to have_css(".checkbox__content")
      expect(page).to have_css(".checkbox__label", text: "Label")
      expect(page).to have_css(".checkbox__description", text: "Description")
    end

    it "does not render content container when label/description are missing" do
      render_inline(described_class.new)

      expect(page).not_to have_css(".checkbox__content")
      expect(page).not_to have_css(".checkbox__label")
      expect(page).not_to have_css(".checkbox__description")
    end
  end

  describe "states" do
    it "renders unchecked by default" do
      render_inline(described_class.new)

      expect(page).to have_css("input.checkbox__input:not([checked])")
      expect(page).not_to have_css(".checkbox--indeterminate")
    end

    it "renders checked state" do
      render_inline(described_class.new(checked: true))

      expect(page).to have_css("input.checkbox__input[checked]")
      expect(page).not_to have_css(".checkbox--indeterminate")
    end

    it "renders indeterminate state (wins over checked)" do
      render_inline(described_class.new(checked: true, indeterminate: true))

      expect(page).to have_css(".checkbox--indeterminate")
      expect(page).to have_css("input.checkbox__input[data-indeterminate='true']")
      expect(page).to have_css("input.checkbox__input[aria-checked='mixed']")
      expect(page).to have_css("input.checkbox__input:not([checked])")
    end

    it "renders disabled state" do
      render_inline(described_class.new(disabled: true))

      expect(page).to have_css(".checkbox--disabled")
      expect(page).to have_css("input.checkbox__input[disabled]")
    end
  end

  describe "attributes" do
    it "passes through standard input attributes" do
      render_inline(described_class.new(
        id: "my-id",
        name: "my-name",
        value: "my-value",
        title: "My title",
        autocomplete: "on"
      ))

      expect(page).to have_css("input.checkbox__input#my-id[name='my-name'][value='my-value'][title='My title'][autocomplete='on']")
    end

    it "merges provided data attributes and adds indeterminate marker when needed" do
      render_inline(described_class.new(
        indeterminate: true,
        data: {foo: "bar"}
      ))

      expect(page).to have_css("input.checkbox__input[data-foo='bar'][data-indeterminate='true']")
    end

    it "applies custom classes on the root element" do
      render_inline(described_class.new(classes: "test-class another"))

      expect(page).to have_css("label.checkbox.test-class.another")
    end
  end
end
