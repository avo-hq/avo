# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabComponent, type: :component do
  include Capybara::RSpecMatchers

  describe "rendering" do
    it "renders a button tab by default with label" do
      render_inline(described_class.new(label: "Settings"))

      expect(page).to have_css("button[type='button']")
      expect(page).to have_css("span.tabs__item-label", text: "Settings")
      expect(page).to have_css(".tabs__item")
      expect(page).to have_css(".tabs__item-wrapper")
    end

    it "renders with scope variant by default" do
      render_inline(described_class.new(label: "Tab"))

      expect(page).to have_css(".tabs__item--scope")
      expect(page).to have_css(".tabs__item-wrapper--scope")
    end

    it "renders as a link when href is provided, button when href is #" do
      render_inline(described_class.new(label: "External", href: "/settings"))
      expect(page).to have_css("a[href='/settings']")
      expect(page).not_to have_css("button")

      render_inline(described_class.new(label: "Tab", href: "#"))
      expect(page).to have_css("button[type='button']")
      expect(page).not_to have_css("a")
    end

    it "applies active class when active, not when inactive" do
      render_inline(described_class.new(label: "Active Tab", active: true))
      expect(page).to have_css(".tabs__item--active")

      render_inline(described_class.new(label: "Inactive Tab", active: false))
      expect(page).not_to have_css(".tabs__item--active")
    end

    it "renders icon when provided, not when absent" do
      render_inline(described_class.new(label: "Settings", icon: "heroicons/outline/cog"))
      expect(page).to have_css(".tabs__item-icon")

      render_inline(described_class.new(label: "Settings"))
      expect(page).not_to have_css(".tabs__item-icon")
    end

    it "renders with custom attributes" do
      render_inline(described_class.new(
        label: "Tab",
        id: "custom-tab-id",
        title: "Click to view settings",
        classes: "my-custom-class",
        data: {testid: "test-tab", action: "click->tabs#select"}
      ))

      expect(page).to have_css("button#custom-tab-id")
      expect(page).to have_css("button[title='Click to view settings']")
      expect(page).to have_css(".tabs__item.my-custom-class")
      expect(page).to have_css("button[data-testid='test-tab'][data-action='click->tabs#select']")
    end
  end

  describe "disabled state" do
    it "disables button with proper attributes and renders as button even with href" do
      render_inline(described_class.new(label: "Disabled Tab", disabled: true))

      expect(page).to have_css("button[disabled]")
      expect(page).to have_css("button[aria-disabled='true']")
      expect(page).to have_css("button[tabindex='-1']")
      expect(page).to have_css(".tabs__item--disabled")
    end

    it "sets tabindex to 0 when enabled" do
      render_inline(described_class.new(label: "Enabled Tab", disabled: false))
      expect(page).to have_css("button[tabindex='0']")
    end

    it "renders as button instead of link when disabled with href" do
      render_inline(described_class.new(label: "Disabled Link", href: "/settings", disabled: true))
      expect(page).to have_css("button[disabled]")
      expect(page).not_to have_css("a")
    end
  end

  describe "ARIA attributes" do
    it "includes proper ARIA attributes" do
      render_inline(described_class.new(label: "Tab", id: "my-tab", active: true))
      expect(page).to have_css("button[role='tab']")
      expect(page).to have_css("button[aria-selected='true']")
      expect(page).to have_css("button[aria-controls='my-tab-panel']")
    end

    it "uses custom aria-controls when provided" do
      render_inline(described_class.new(label: "Tab", aria_controls: "custom-panel"))
      expect(page).to have_css("button[aria-controls='custom-panel']")
    end

    it "sets aria-selected to false when inactive" do
      render_inline(described_class.new(label: "Inactive", active: false))
      expect(page).to have_css("button[aria-selected='false']")
    end
  end

  describe "data attributes" do
    it "sets tab_active_class and preserves custom data attributes" do
      render_inline(described_class.new(
        label: "Tab",
        data: {custom: "value", tab_active_class: "my-active-class"}
      ))

      expect(page).to have_css("button[data-tab-active-class='my-active-class']")
      expect(page).to have_css("button[data-custom='value']")
    end
  end

  describe "#link?" do
    it "returns true when href is present and not #" do
      component = described_class.new(label: "Tab", href: "/settings")
      expect(component.link?).to be true
    end

    it "returns false when href is #, nil, or disabled" do
      expect(described_class.new(label: "Tab", href: "#").link?).to be false
      expect(described_class.new(label: "Tab").link?).to be false
      expect(described_class.new(label: "Tab", href: "/settings", disabled: true).link?).to be false
    end
  end

  describe "variants" do
    shared_examples "variant styling" do |variant_name|
      it "applies #{variant_name} variant classes" do
        render_inline(described_class.new(label: "Tab", variant: variant_name))

        expect(page).to have_css(".tabs__item--#{variant_name}")
        expect(page).to have_css(".tabs__item-wrapper--#{variant_name}")
      end
    end

    include_examples "variant styling", :group
    include_examples "variant styling", :scope

    describe "active state behavior" do
      it "applies active class to wrapper for scope variant (default)" do
        render_inline(described_class.new(label: "Tab", active: true))
        expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
        expect(page).to have_css(".tabs__item--scope.tabs__item--active")
      end

      it "applies active class only to item for group variant" do
        render_inline(described_class.new(label: "Tab", variant: :group, active: true))
        expect(page).to have_css(".tabs__item--group.tabs__item--active")
        expect(page).not_to have_css(".tabs__item-wrapper--group.tabs__item--active")
      end
    end

    describe "scope variant (default)" do
      it "renders with all features by default" do
        render_inline(described_class.new(
          label: "Scope Tab",
          active: true,
          icon: "heroicons/outline/filter",
          href: "/filter/published",
          id: "scope-published",
          data: {testid: "published-scope"}
        ))

        expect(page).to have_css("a#scope-published[href='/filter/published']")
        expect(page).to have_css(".tabs__item-icon")
        expect(page).to have_css("[data-testid='published-scope']")
        expect(page).to have_css(".tabs__item--active")
        expect(page).to have_text("Scope Tab")
      end

      it "uses scope classes by default, not group" do
        render_inline(described_class.new(label: "Tab"))
        expect(page).to have_css(".tabs__item--scope")
        expect(page).not_to have_css(".tabs__item--group")
      end
    end

    it "applies disabled class regardless of variant" do
      render_inline(described_class.new(label: "Tab", disabled: true))
      expect(page).to have_css(".tabs__item--scope.tabs__item--disabled")
    end
  end
end
