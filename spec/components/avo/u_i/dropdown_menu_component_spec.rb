require "rails_helper"

RSpec.describe Avo::UI::DropdownMenuComponent, type: :component do
  describe "rendering" do
    it "adds default dropdown data attributes" do
      render_inline(described_class.new) do |menu|
        menu.with_item(title: "View")
      end

      expect(page).to have_css('[data-dropdown-target="dropdownMenuComponent"]')
      expect(page).to have_css('[data-transition-enter="transition ease-out duration-100"]')
      expect(page).to have_css('[data-transition-enter-start="transform opacity-0 -translate-y-1"]')
      expect(page).to have_css('[data-transition-enter-end="transform opacity-100 translate-y-0"]')
      expect(page).to have_css('[data-transition-leave="transition ease-in duration-75"]')
      expect(page).to have_css('[data-transition-leave-start="transform opacity-100 translate-y-0"]')
      expect(page).to have_css('[data-transition-leave-end="transform opacity-0 -translate-y-1"]')
    end

    it "merges custom data attributes" do
      render_inline(described_class.new(data: {test_id: "dropdown-menu"})) do |menu|
        menu.with_item(title: "Delete")
      end

      expect(page).to have_css('[data-test-id="dropdown-menu"]')
      # Should still have default attributes
      expect(page).to have_css('[data-dropdown-target="dropdownMenuComponent"]')
    end

    it "applies hidden class by default" do
      render_inline(described_class.new) do |menu|
        menu.with_item(title: "Edit")
      end

      expect(page).to have_css(".dropdown-menu.hidden")
    end

    it "does not apply hidden class when hidden is false" do
      render_inline(described_class.new(hidden: false)) do |menu|
        menu.with_item(title: "Edit")
      end

      expect(page).to have_css(".dropdown-menu")
      expect(page).not_to have_css(".dropdown-menu.hidden")
    end

    it "applies custom classes" do
      render_inline(described_class.new(classes: "custom-class another-class")) do |menu|
        menu.with_item(title: "Edit")
      end

      expect(page).to have_css(".dropdown-menu.custom-class.another-class")
    end
  end
end
