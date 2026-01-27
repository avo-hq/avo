# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabComponent, type: :component do
  include Capybara::RSpecMatchers

  subject(:component) { described_class.new(**options) }

  let(:options) { {label: "Tab"} }

  def render_component(**opts)
    render_inline(described_class.new(**options.merge(opts)))
  end

  describe "rendering" do
    it "renders a button tab by default" do
      render_component

      expect(page).to have_css("button[type='button']")
      expect(page).to have_css("span.tabs__item-label", text: "Tab")
      expect(page).to have_css(".tabs__item")
      expect(page).to have_css(".tabs__item-wrapper")
    end

    it "renders with scope variant by default" do
      render_component

      expect(page).to have_css(".tabs__item-wrapper--scope")
      expect(page).not_to have_css(".tabs__item--scope")
      expect(page).not_to have_css(".tabs__item--group")
    end

    context "with href" do
      it "renders as link when href is a path" do
        render_component(href: "/settings")

        expect(page).to have_css("a[href='/settings']")
        expect(page).not_to have_css("button")
      end

      it "renders as link when href is #" do
        render_component(href: "#")

        expect(page).to have_css("a[href='#']")
        expect(page).not_to have_css("button")
      end
    end

    context "with active state" do
      it "applies active class when active" do
        render_component(active: true)
        expect(page).to have_css(".tabs__item--active")
      end

      it "omits active class when inactive" do
        render_component(active: false)
        expect(page).not_to have_css(".tabs__item--active")
      end
    end

    context "with icon" do
      it "renders icon when provided" do
        render_component(icon: "heroicons/outline/cog")
        expect(page).to have_css(".tabs__item-icon")
      end

      it "omits icon when not provided" do
        render_component
        expect(page).not_to have_css(".tabs__item-icon")
      end
    end

    it "renders with custom attributes" do
      render_component(
        id: "custom-tab-id",
        title: "Click to view settings",
        classes: "my-custom-class",
        data: {testid: "test-tab", action: "click->tabs#select"}
      )

      expect(page).to have_css("button#custom-tab-id")
      expect(page).to have_css("button[title='Click to view settings']")
      expect(page).to have_css(".tabs__item.my-custom-class")
      expect(page).to have_css("button[data-testid='test-tab'][data-action='click->tabs#select']")
    end
  end

  describe "disabled state" do
    it "applies disabled attributes to button" do
      render_component(disabled: true)

      expect(page).to have_css("button[disabled]")
      expect(page).to have_css("button[aria-disabled='true']")
      expect(page).to have_css("button[tabindex='-1']")
      expect(page).to have_css(".tabs__item--disabled")
    end

    it "sets tabindex to 0 when enabled" do
      render_component(disabled: false)
      expect(page).to have_css("button[tabindex='0']")
    end
  end

  describe "ARIA attributes" do
    it "includes proper ARIA attributes" do
      render_component(id: "my-tab", active: true)

      expect(page).to have_css("button[role='tab']")
      expect(page).to have_css("button[aria-selected='true']")
      expect(page).to have_css("button[id='my-tab']")
      expect(page).to have_css("button[aria-controls]")
    end

    it "uses custom aria-controls when provided" do
      render_component(aria_controls: "custom-panel")
      expect(page).to have_css("button[aria-controls='custom-panel']")
    end

    it "sets aria-selected based on active state" do
      render_component(active: false)
      expect(page).to have_css("button[aria-selected='false']")
    end
  end

  describe "data attributes" do
    it "preserves custom data attributes" do
      render_component(data: {custom: "value"})
      expect(page).to have_css("button[data-custom='value']")
    end
  end


  describe "variants" do
    describe "group variant" do
      it "applies group variant classes" do
        render_component(variant: :group)

        expect(page).to have_css(".tabs__item--group")
        expect(page).to have_css(".tabs__item-wrapper--group")
      end

      it "applies active class only to item, not wrapper" do
        render_component(variant: :group, active: true)

        expect(page).to have_css(".tabs__item--group.tabs__item--active")
        expect(page).not_to have_css(".tabs__item-wrapper--group.tabs__item--active")
      end
    end

    describe "scope variant" do
      it "applies wrapper classes but not item variant classes" do
        render_component(variant: :scope)

        expect(page).to have_css(".tabs__item-wrapper--scope")
        expect(page).not_to have_css(".tabs__item--scope")
      end

      it "applies active class to both wrapper and item" do
        render_component(active: true)

        expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
        expect(page).to have_css(".tabs__item.tabs__item--active")
      end

      it "renders with all features" do
        render_component(
          label: "Scope Tab",
          active: true,
          icon: "heroicons/outline/filter",
          href: "/filter/published",
          id: "scope-published",
          data: {testid: "published-scope"}
        )

        expect(page).to have_css("a#scope-published[href='/filter/published']")
        expect(page).to have_css(".tabs__item-icon")
        expect(page).to have_css("[data-testid='published-scope']")
        expect(page).to have_css(".tabs__item--active")
        expect(page).to have_text("Scope Tab")
      end
    end

    it "applies disabled class regardless of variant" do
      render_component(disabled: true)
      expect(page).to have_css(".tabs__item.tabs__item--disabled")
    end
  end
end
