# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabComponent, type: :component do
  include Capybara::RSpecMatchers

  describe "rendering" do
    it "renders a button tab by default" do
      render_inline(described_class.new(label: "Settings"))

      expect(page).to have_css("button[type='button']")
      expect(page).to have_css("span.tabs__item-label", text: "Settings")
    end

    it "renders with the group variant by default" do
      render_inline(described_class.new(label: "Tab"))

      expect(page).to have_css(".tabs__item--group")
      expect(page).to have_css(".tabs__item-wrapper--group")
    end

    it "renders with the scope variant when specified" do
      render_inline(described_class.new(label: "Tab", variant: :scope))

      expect(page).to have_css(".tabs__item--scope")
      expect(page).to have_css(".tabs__item-wrapper--scope")
    end

    it "renders as a link when href is provided" do
      render_inline(described_class.new(label: "External", href: "/settings"))

      expect(page).to have_css("a[href='/settings']")
      expect(page).not_to have_css("button")
    end

    it "renders as a button when href is #" do
      render_inline(described_class.new(label: "Tab", href: "#"))

      expect(page).to have_css("button[type='button']")
      expect(page).not_to have_css("a")
    end

    it "applies active class when active" do
      render_inline(described_class.new(label: "Active Tab", active: true))

      expect(page).to have_css(".tabs__item--active")
    end

    it "does not apply active class when not active" do
      render_inline(described_class.new(label: "Inactive Tab", active: false))

      expect(page).not_to have_css(".tabs__item--active")
    end

    it "renders with icon when provided" do
      render_inline(described_class.new(label: "Settings", icon: "heroicons/outline/cog"))

      expect(page).to have_css(".tabs__item-icon")
    end

    it "does not render icon when not provided" do
      render_inline(described_class.new(label: "Settings"))

      expect(page).not_to have_css(".tabs__item-icon")
    end

    it "renders with custom id" do
      render_inline(described_class.new(label: "Tab", id: "custom-tab-id"))

      expect(page).to have_css("button#custom-tab-id")
    end

    it "renders with title attribute" do
      render_inline(described_class.new(label: "Tab", title: "Click to view settings"))

      expect(page).to have_css("button[title='Click to view settings']")
    end

    it "renders with custom classes" do
      render_inline(described_class.new(label: "Tab", classes: "my-custom-class"))

      expect(page).to have_css(".tabs__item.my-custom-class")
    end

    it "renders with custom data attributes" do
      render_inline(described_class.new(label: "Tab", data: {testid: "test-tab", action: "click->tabs#select"}))

      expect(page).to have_css("button[data-testid='test-tab'][data-action='click->tabs#select']")
    end
  end

  describe "disabled state" do
    it "disables the button when disabled is true" do
      render_inline(described_class.new(label: "Disabled Tab", disabled: true))

      expect(page).to have_css("button[disabled]")
      expect(page).to have_css("button[aria-disabled='true']")
      expect(page).to have_css(".tabs__item--disabled")
    end

    it "sets tabindex to -1 when disabled" do
      render_inline(described_class.new(label: "Disabled Tab", disabled: true))

      expect(page).to have_css("button[tabindex='-1']")
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
    it "includes role=tab" do
      render_inline(described_class.new(label: "Tab"))

      expect(page).to have_css("button[role='tab']")
    end

    it "sets aria-selected to true when active" do
      render_inline(described_class.new(label: "Active", active: true))

      expect(page).to have_css("button[aria-selected='true']")
    end

    it "sets aria-selected to false when inactive" do
      render_inline(described_class.new(label: "Inactive", active: false))

      expect(page).to have_css("button[aria-selected='false']")
    end

    it "includes aria-controls attribute" do
      render_inline(described_class.new(label: "Tab", id: "my-tab"))

      expect(page).to have_css("button[aria-controls='my-tab-panel']")
    end

    it "uses custom aria-controls when provided" do
      render_inline(described_class.new(label: "Tab", aria_controls: "custom-panel"))

      expect(page).to have_css("button[aria-controls='custom-panel']")
    end
  end

  describe "wrapper classes" do
    it "applies active class to wrapper for scope variant when active" do
      render_inline(described_class.new(label: "Tab", variant: :scope, active: true))

      expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
    end

    it "does not apply active class to wrapper for group variant" do
      render_inline(described_class.new(label: "Tab", variant: :group, active: true))

      expect(page).not_to have_css(".tabs__item-wrapper.tabs__item--active")
    end
  end

  describe "data attributes" do
    it "sets tab_active_class in data attributes" do
      render_inline(described_class.new(label: "Tab"))

      expect(page).to have_css("button[data-tab-active-class='tabs__item--active']")
    end

    it "preserves custom data attributes" do
      render_inline(described_class.new(
        label: "Tab",
        data: {custom: "value", tab_active_class: "my-active-class"}
      ))

      expect(page).to have_css("button[data-custom='value']")
      # Custom tab_active_class should not override the default
      expect(page).to have_css("button[data-tab-active-class='my-active-class']")
    end
  end

  describe "#link?" do
    it "returns true when href is present and not #" do
      component = described_class.new(label: "Tab", href: "/settings")
      expect(component.link?).to be true
    end

    it "returns false when href is #" do
      component = described_class.new(label: "Tab", href: "#")
      expect(component.link?).to be false
    end

    it "returns false when href is nil" do
      component = described_class.new(label: "Tab")
      expect(component.link?).to be false
    end

    it "returns false when disabled even with valid href" do
      component = described_class.new(label: "Tab", href: "/settings", disabled: true)
      expect(component.link?).to be false
    end
  end

  # CSS class structure tests based on tabs.css
  describe "CSS class structure" do
    describe "base styles (.tabs__item)" do
      it "applies the base .tabs__item class for styling" do
        render_inline(described_class.new(label: "Tab"))

        expect(page).to have_css(".tabs__item")
      end

      it "applies .tabs__item-label for label text" do
        render_inline(described_class.new(label: "My Tab"))

        expect(page).to have_css(".tabs__item-label", text: "My Tab")
      end

      it "applies .tabs__item-icon for icon element" do
        render_inline(described_class.new(label: "Tab", icon: "heroicons/outline/cog"))

        expect(page).to have_css(".tabs__item-icon")
      end

      it "applies .tabs__item-wrapper for outer container" do
        render_inline(described_class.new(label: "Tab"))

        expect(page).to have_css(".tabs__item-wrapper")
      end
    end

    describe "group variant CSS" do
      it "applies .tabs__item--group for group-specific item styling" do
        render_inline(described_class.new(label: "Tab", variant: :group))

        expect(page).to have_css(".tabs__item.tabs__item--group")
      end

      it "applies .tabs__item-wrapper--group for group wrapper" do
        render_inline(described_class.new(label: "Tab", variant: :group))

        expect(page).to have_css(".tabs__item-wrapper.tabs__item-wrapper--group")
      end

      it "applies .tabs__item--active for active group tab (background styling)" do
        render_inline(described_class.new(label: "Tab", variant: :group, active: true))

        # .tabs__item--group.tabs__item--active gets background color
        expect(page).to have_css(".tabs__item--group.tabs__item--active")
      end

      it "does not apply active class to wrapper for group variant" do
        render_inline(described_class.new(label: "Tab", variant: :group, active: true))

        # Group variant doesn't use wrapper active class (only item has it)
        expect(page).not_to have_css(".tabs__item-wrapper--group.tabs__item--active")
      end
    end

    describe "scope variant CSS" do
      it "applies .tabs__item--scope for scope-specific item styling (rounded-none)" do
        render_inline(described_class.new(label: "Tab", variant: :scope))

        expect(page).to have_css(".tabs__item.tabs__item--scope")
      end

      it "applies .tabs__item-wrapper--scope for bottom border" do
        render_inline(described_class.new(label: "Tab", variant: :scope))

        expect(page).to have_css(".tabs__item-wrapper.tabs__item-wrapper--scope")
      end

      it "applies .tabs__item--active to wrapper for scope variant (thicker bottom border)" do
        render_inline(described_class.new(label: "Tab", variant: :scope, active: true))

        # Scope variant uses wrapper active class for underline CSS
        expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
      end

      it "applies .tabs__item--active to both wrapper and item for scope variant" do
        render_inline(described_class.new(label: "Tab", variant: :scope, active: true))

        expect(page).to have_css(".tabs__item--scope.tabs__item--active")
        expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
      end
    end

    describe "disabled state CSS (.tabs__item--disabled)" do
      it "applies .tabs__item--disabled for disabled styling (opacity/cursor)" do
        render_inline(described_class.new(label: "Tab", disabled: true))

        expect(page).to have_css(".tabs__item.tabs__item--disabled")
      end

      it "applies disabled class regardless of variant" do
        render_inline(described_class.new(label: "Tab", variant: :scope, disabled: true))

        expect(page).to have_css(".tabs__item--scope.tabs__item--disabled")
      end
    end
  end
end
