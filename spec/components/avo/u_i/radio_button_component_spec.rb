require "rails_helper"

RSpec.describe Avo::UI::RadioButtonComponent, type: :component do
  describe "rendering" do
    it "renders default radio button (unchecked, enabled)" do
      render_inline(described_class.new(label: "Label", description: "Description", name: "test"))

      expect(page).to have_css(".radio-button")
      expect(page).not_to have_css(".radio-button--disabled")
      expect(page).to have_css("input[type='radio'].radio-button__input:not([disabled])")
      expect(page).to have_text("Label")
      expect(page).to have_text("Description")
    end

    it "renders without description when description is nil" do
      render_inline(described_class.new(label: "Label", description: nil, name: "test"))

      expect(page).to have_css(".radio-button")
      expect(page).to have_css(".radio-button__label")
      expect(page).not_to have_css(".radio-button__description")
      expect(page).to have_text("Label")
    end

    it "renders without label when label is nil" do
      render_inline(described_class.new(label: nil, description: "Description", name: "test"))

      expect(page).to have_css(".radio-button")
      expect(page).not_to have_css(".radio-button__label")
      expect(page).to have_text("Description")
    end

    it "renders checked state" do
      render_inline(described_class.new(label: "Label", checked: true, name: "test"))

      expect(page).to have_css("input[type='radio'][checked]")
    end

    it "renders disabled state" do
      render_inline(described_class.new(label: "Label", disabled: true, name: "test"))

      expect(page).to have_css(".radio-button--disabled")
      expect(page).to have_css("input[type='radio'][disabled]")
    end
  end

  describe "edge cases" do
    it "handles nil label gracefully" do
      expect {
        render_inline(described_class.new(label: nil, name: "test"))
      }.not_to raise_error
    end

    it "handles empty string label" do
      render_inline(described_class.new(label: "", name: "test"))

      expect(page).to have_css(".radio-button")
      expect(page).not_to have_css(".radio-button__label")
    end

    it "handles missing name/id/value gracefully" do
      expect {
        render_inline(described_class.new(label: "Label"))
      }.not_to raise_error

      expect(page).to have_css("input[type='radio'].radio-button__input")
    end
  end
end
