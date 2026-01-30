require "rails_helper"

RSpec.describe Avo::UI::DropdownMenuComponent, type: :component do
  describe "rendering" do
    it "renders as a dialog element" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).to have_css("dialog.dropdown-popover")
    end

    it "has the closedby attribute set to 'any'" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).to have_css("dialog[closedby='any']")
    end

    it "renders the dropdown-menu__list wrapper" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).to have_css(".dropdown-menu__list", text: "Menu content")
    end

    it "renders content inside the list" do
      render_inline(described_class.new) do
        # Simple text content - in real usage, this would be link_to, button_tag, etc.
        "Edit"
      end

      expect(page).to have_css(".dropdown-menu__list", text: "Edit")
      expect(page).to have_text("Edit")
    end

    it "merges custom data attributes" do
      render_inline(described_class.new(data: {test_id: "dropdown-menu", dropdown_menu_target: "menu"})) do
        "Menu content"
      end

      expect(page).to have_css('[data-test-id="dropdown-menu"]')
      expect(page).to have_css('[data-dropdown-menu-target="menu"]')
    end

    it "applies custom classes" do
      render_inline(described_class.new(classes: "custom-class another-class")) do
        "Menu content"
      end

      expect(page).to have_css("dialog.dropdown-popover.custom-class.another-class")
    end

    it "applies default dropdown-popover class" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).to have_css(".dropdown-popover")
    end

    it "renders the dropdown-menu wrapper" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).to have_css(".dropdown-menu")
    end

    it "does not have open attribute by default" do
      render_inline(described_class.new) do
        "Menu content"
      end

      expect(page).not_to have_css("dialog[open]")
    end
  end

  describe "data attributes" do
    it "allows setting dropdown_menu_target via data prop" do
      render_inline(described_class.new(data: {dropdown_menu_target: "menu"})) do
        "Menu content"
      end

      expect(page).to have_css('[data-dropdown-menu-target="menu"]')
    end

    it "merges multiple data attributes" do
      render_inline(described_class.new(data: {
        dropdown_menu_target: "menu",
        controller: "dropdown-menu",
        action: "click->dropdown-menu#close"
      })) do
        "Menu content"
      end

      expect(page).to have_css('[data-dropdown-menu-target="menu"]')
      expect(page).to have_css('[data-controller="dropdown-menu"]')
      expect(page).to have_css('[data-action="click->dropdown-menu#close"]')
    end
  end

  describe "edge cases" do
    it "handles empty content gracefully" do
      expect {
        render_inline(described_class.new) do
          ""
        end
      }.not_to raise_error

      expect(page).to have_css("dialog.dropdown-popover")
      expect(page).to have_css(".dropdown-menu__list")
    end

    it "handles nil classes gracefully" do
      expect {
        render_inline(described_class.new(classes: nil)) do
          "Menu content"
        end
      }.not_to raise_error

      expect(page).to have_css("dialog.dropdown-popover")
    end

    it "handles empty data hash" do
      expect {
        render_inline(described_class.new(data: {})) do
          "Menu content"
        end
      }.not_to raise_error

      expect(page).to have_css("dialog.dropdown-popover")
    end
  end
end
