require "rails_helper"

RSpec.describe Avo::UI::DropdownComponent, type: :component do
  describe "rendering" do
    it "renders the wrapper with the dropdown-menu controller" do
      render_inline(described_class.new) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css('[data-controller="dropdown-menu"]')
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

    it "renders a search input and empty state when searchable in popover mode" do
      render_inline(described_class.new(popover_mode: true, searchable: true)) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).to have_css('.dropdown-menu__search input[data-popover-menu-target="searchInput"][placeholder="Search"]')
      expect(page).to have_css('.dropdown-menu__search-empty[data-popover-menu-target="empty"][hidden]', visible: :hidden)
    end

    it "does not render a search input when not searchable" do
      render_inline(described_class.new(popover_mode: true)) do |component|
        component.with_trigger { "Trigger" }
        component.with_items { "Item" }
      end

      expect(page).not_to have_css(".dropdown-menu__search")
    end
  end
end
