require "rails_helper"

RSpec.describe Avo::UI::DropdownComponent, type: :component do
  describe "rendering" do
    it "renders the wrapper with anchor-name style" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css(".dropdown[style*='anchor-name']")
    end

    it "renders the popover shell" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css(".popover-anchor[popover]")
    end

    it "renders the trigger slot" do
      render_inline(described_class.new) do |component|
        component.with_trigger do
          "<span class='dropdown-trigger'>Trigger</span>".html_safe
        end
        component.with_items { "Item" }
      end

      expect(page).to have_css(".dropdown-trigger", text: "Trigger")
    end

    it "renders items inside the dropdown menu list" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items do
          "FirstSecond"
        end
      end

      expect(page).to have_css(".dropdown-menu__list", text: "First")
      expect(page).to have_css(".dropdown-menu__list", text: "Second")
    end
  end
end
