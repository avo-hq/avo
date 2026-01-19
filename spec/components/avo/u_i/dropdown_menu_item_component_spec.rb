require "rails_helper"

RSpec.describe Avo::UI::DropdownMenuItemComponent, type: :component do
  describe "rendering" do
    it "renders a button when no url is provided" do
      render_inline(described_class.new(title: "Edit"))

      expect(page).to have_css('button.dropdown-menu__item[type="button"]')
      expect(page).to have_css(".dropdown-menu__label", text: "Edit")
      expect(page).to have_text("Edit")
    end

    it "renders a link when url is provided" do
      render_inline(described_class.new(title: "View", url: "/view"))

      expect(page).to have_css('a.dropdown-menu__item[href="/view"]')
      expect(page).to have_css(".dropdown-menu__label", text: "View")
      expect(page).to have_text("View")
    end

    it "adds the close action by default" do
      render_inline(described_class.new(title: "Delete"))

      expect(page).to have_css('[data-action="click->dropdown#dropdownItemActions"]')
    end

    it "renders an icon when provided" do
      render_inline(described_class.new(title: "Edit", icon: "tabler/outline/pencil"))

      expect(page).to have_css(".dropdown-menu__icon")
      expect(page).to have_css("svg.dropdown-menu__icon")
    end

    it "does not render icon when not provided" do
      render_inline(described_class.new(title: "Edit"))

      expect(page).not_to have_css(".dropdown-menu__icon")
    end

    it "renders button with custom type" do
      render_inline(described_class.new(title: "Submit", type: "submit"))

      expect(page).to have_css('button.dropdown-menu__item[type="submit"]')
    end

    it "renders link with method attribute" do
      render_inline(described_class.new(title: "Delete", url: "/delete", method: :delete))

      expect(page).to have_css('a.dropdown-menu__item[href="/delete"][data-method="delete"]')
    end

    it "renders link with target attribute" do
      render_inline(described_class.new(title: "Open", url: "/open", target: "_blank"))

      expect(page).to have_css('a.dropdown-menu__item[href="/open"][target="_blank"]')
    end

    it "adds turbo data attribute when turbo is true" do
      render_inline(described_class.new(title: "Link", url: "/link", turbo: true))

      expect(page).to have_css('a.dropdown-menu__item[data-turbo="true"]')
    end

    it "adds turbo data attribute when turbo is false" do
      render_inline(described_class.new(title: "Link", url: "/link", turbo: false))

      expect(page).to have_css('a.dropdown-menu__item[data-turbo="false"]')
    end

    it "does not add turbo data attribute when turbo is nil" do
      render_inline(described_class.new(title: "Link", url: "/link"))

      expect(page).not_to have_css("[data-turbo]")
    end

    it "merges custom data attributes" do
      render_inline(described_class.new(
        title: "Custom",
        data: {test_id: "menu-item", custom_attr: "value"}
      ))

      expect(page).to have_css('[data-test-id="menu-item"]')
      expect(page).to have_css('[data-custom-attr="value"]')
      # Should still have default action
      expect(page).to have_css('[data-action="click->dropdown#dropdownItemActions"]')
    end

    it "applies custom classes" do
      render_inline(described_class.new(title: "Custom", classes: "custom-class another-class"))

      expect(page).to have_css(".dropdown-menu__item.custom-class.another-class")
    end

    it "renders both icon and label together" do
      render_inline(described_class.new(
        title: "Edit Item",
        icon: "tabler/outline/pencil",
        url: "/edit"
      ))

      expect(page).to have_css(".dropdown-menu__label", text: "Edit Item")
      expect(page).to have_css(".dropdown-menu__icon")
      expect(page).to have_text("Edit Item")
    end
  end
end
