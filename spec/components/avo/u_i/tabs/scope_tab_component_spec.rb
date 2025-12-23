# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::ScopeTabComponent, type: :component do
  describe "rendering" do
    it "renders with scope variant by default" do
      render_inline(described_class.new(label: "All"))

      expect(page).to have_css(".tabs__item--scope")
      expect(page).to have_css(".tabs__item-wrapper--scope")
    end

    it "renders the tab with proper label" do
      render_inline(described_class.new(label: "Published"))

      expect(page).to have_css("span.tabs__item-label", text: "Published")
    end

    it "applies active class to wrapper when active (scope variant behavior)" do
      render_inline(described_class.new(label: "Active Scope", active: true))

      expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
    end

    it "renders with all TabComponent features" do
      render_inline(described_class.new(
        label: "Scope Tab",
        active: true,
        icon: "heroicons/outline/filter",
        href: "/filter/published",
        id: "scope-published",
        data: {testid: "published-scope"}
      ))

      expect(page).to have_css("a#scope-published")
      expect(page).to have_css("a[href='/filter/published']")
      expect(page).to have_css(".tabs__item-icon")
      expect(page).to have_css("[data-testid='published-scope']")
      expect(page).to have_css(".tabs__item--active")
      expect(page).to have_text("Scope Tab")
    end
  end

  describe "inheritance" do
    it "inherits from TabComponent" do
      expect(described_class).to be < Avo::UI::Tabs::TabComponent
    end
  end

  # CSS class structure tests based on tabs.css (scope variant specific)
  describe "CSS class structure (scope variant)" do
    it "applies .tabs__item--scope for rounded-none styling" do
      render_inline(described_class.new(label: "Tab"))

      expect(page).to have_css(".tabs__item.tabs__item--scope")
    end

    it "applies .tabs__item-wrapper--scope for bottom border" do
      render_inline(described_class.new(label: "Tab"))

      # .tabs__item-wrapper--scope has border-bottom styling
      expect(page).to have_css(".tabs__item-wrapper.tabs__item-wrapper--scope")
    end

    it "applies active class to wrapper for thicker bottom border underline" do
      render_inline(described_class.new(label: "Tab", active: true))

      # .tabs__item-wrapper--scope.tabs__item--active has 2px bottom border
      expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
    end

    it "applies active class to both item and wrapper" do
      render_inline(described_class.new(label: "Tab", active: true))

      # Both should have active class for scope variant
      expect(page).to have_css(".tabs__item--scope.tabs__item--active")
      expect(page).to have_css(".tabs__item-wrapper--scope.tabs__item--active")
    end

    it "provides scope variant by default (no need to specify variant)" do
      render_inline(described_class.new(label: "Tab"))

      # Should have scope classes, not group
      expect(page).to have_css(".tabs__item--scope")
      expect(page).to have_css(".tabs__item-wrapper--scope")
      expect(page).not_to have_css(".tabs__item--group")
      expect(page).not_to have_css(".tabs__item-wrapper--group")
    end
  end
end
