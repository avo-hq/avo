require "rails_helper"

RSpec.describe Avo::UI::TextInputComponent, type: :component do
  describe "rendering" do
    it "renders default text input with enabled state" do
      render_inline(described_class.new(label: "Label"))

      expect(page).to have_css(".text-input")
      expect(page).to have_css("input[placeholder='Label']")
    end

    it "renders hint when provided" do
      render_inline(described_class.new(label: "Label", hint: "Help text"))

      expect(page).to have_css(".text-input__hint", text: "Help text")
    end
  end

  describe "prop-driven states" do
    it "renders error style with error message" do
      render_inline(described_class.new(
        label: "Label",
        value: "Value",
        error_message: "Error message",
        error: true
      ))

      expect(page).to have_css(".text-input--error")
      expect(page).to have_css(".text-input__error-text", text: "Error message")
      expect(page).to have_css("input[aria-invalid='true']")
    end

    it "renders loading spinner when loading is true" do
      render_inline(described_class.new(
        label: "Label",
        value: "Value",
        hint: "Help text",
        loading: true
      ))

      expect(page).to have_css(".text-input--loading")
      expect(page).to have_css(".text-input__spinner")
    end

    it "marks input disabled when disabled is true" do
      render_inline(described_class.new(label: "Label", disabled: true))

      expect(page).to have_css(".text-input--disabled")
      expect(page).to have_css("input[disabled]")
    end

    it "marks input readonly when readonly is true" do
      render_inline(described_class.new(label: "Label", value: "Value", readonly: true))

      expect(page).to have_css(".text-input--read-only")
      expect(page).to have_css("input[readonly]")
    end

    it "does not render hint when readonly is true" do
      render_inline(described_class.new(label: "Label", hint: "Help text", readonly: true))

      expect(page).not_to have_css(".text-input__hint")
    end

    it "does not render hint when error is true" do
      render_inline(described_class.new(label: "Label", hint: "Help text", error: true))

      expect(page).not_to have_css(".text-input__hint")
    end
  end
end
