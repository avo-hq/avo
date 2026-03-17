require "rails_helper"

RSpec.describe Avo::UI::PopoverComponent, type: :component do
  describe "rendering" do
    it "renders as a dialog element" do
      render_inline(described_class.new) do
        "Popover content"
      end

      expect(page).to have_css("dialog.popover-dialog")
    end

    it "renders content inside the popover body by default" do
      render_inline(described_class.new) do
        "Popover content"
      end

      expect(page).to have_css(".popover__body", text: "Popover content")
    end

    it "renders header, body, and footer slots" do
      render_inline(described_class.new) do |component|
        component.with_header { "Header action" }
        component.with_body { "Body content" }
        component.with_footer { "Footer action" }
      end

      expect(page).to have_css(".popover__header", text: "Header action")
      expect(page).to have_css(".popover__body", text: "Body content")
      expect(page).to have_css(".popover__footer", text: "Footer action")
    end

    it "applies custom classes" do
      render_inline(described_class.new(classes: "custom-class another-class")) do
        "Popover content"
      end

      expect(page).to have_css("dialog.popover-dialog.custom-class.another-class")
    end

    it "does not have open attribute by default" do
      render_inline(described_class.new) do
        "Popover content"
      end

      expect(page).not_to have_css("dialog[open]")
    end
  end

  describe "data attributes" do
    it "merges custom data attributes" do
      render_inline(described_class.new(data: {test_id: "popover"})) do
        "Popover content"
      end

      expect(page).to have_css('[data-test-id="popover"]')
    end
  end
end
