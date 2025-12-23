# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::ScopeTabsComponent, type: :component do
  describe "rendering" do
    it "renders with scope variant by default" do
      render_inline(described_class.new)

      expect(page).to have_css(".tabs--scope")
    end

    it "renders the tabs container with proper attributes" do
      render_inline(described_class.new(id: "scope-tabs", aria_label: "Filter tabs"))

      expect(page).to have_css("div#scope-tabs")
      expect(page).to have_css("div[role='tablist']")
      expect(page).to have_css("div[aria-label='Filter tabs']")
    end

    it "renders content block" do
      render_inline(described_class.new) do
        "<span class='scope-tab'>All Items</span>".html_safe
      end

      expect(page).to have_css(".scope-tab", text: "All Items")
    end
  end

  describe "inheritance" do
    it "inherits from TabsComponent" do
      expect(described_class).to be < Avo::UI::Tabs::TabsComponent
    end
  end

  # CSS class structure tests based on tabs.css
  describe "CSS class structure (scope variant)" do
    it "applies .tabs.tabs--scope for scope container" do
      render_inline(described_class.new)

      expect(page).to have_css(".tabs.tabs--scope")
    end

    it "provides scope variant by default (no need to specify variant)" do
      render_inline(described_class.new)

      # Should have scope, not group
      expect(page).to have_css(".tabs--scope")
      expect(page).not_to have_css(".tabs--group")
    end
  end
end
