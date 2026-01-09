# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabsComponent, type: :component do
  describe "rendering" do
    it "renders the tabs container with scope variant by default and proper attributes" do
      render_inline(described_class.new)

      expect(page).to have_css("div.tabs.tabs--scope")
      expect(page).to have_css("div[role='tablist']")
      expect(page).to have_css("div[aria-label='Tabs navigation']")
      expect(page).to have_css("div[id^='tabs-']")
    end

    it "renders with group variant when specified" do
      render_inline(described_class.new(variant: :group))
      expect(page).to have_css("div.tabs.tabs--group")
    end

    it "renders with custom id and aria-label" do
      render_inline(described_class.new(id: "custom-tabs", aria_label: "Main Navigation"))

      expect(page).to have_css("div#custom-tabs")
      expect(page).to have_css("div[aria-label='Main Navigation']")
    end

    it "renders content block" do
      render_inline(described_class.new) do
        "<span class='tab-content'>Tab 1</span>".html_safe
      end

      expect(page).to have_css(".tab-content", text: "Tab 1")
    end
  end

  describe "#classes" do
    it "returns scope variant classes by default" do
      component = described_class.new
      expect(component.classes).to eq "tabs tabs--scope"
    end

    it "returns group variant classes when specified" do
      component = described_class.new(variant: :group)
      expect(component.classes).to eq "tabs tabs--group"
    end
  end

  describe "#tablist_id" do
    it "returns custom id when provided, generates one when not" do
      component = described_class.new(id: "my-tabs")
      expect(component.tablist_id).to eq "my-tabs"

      component = described_class.new
      expect(component.tablist_id).to start_with("tabs-")
    end
  end

  describe "#tablist_aria_label" do
    it "returns custom aria-label when provided, default when not" do
      component = described_class.new(aria_label: "Custom Label")
      expect(component.tablist_aria_label).to eq "Custom Label"

      component = described_class.new
      expect(component.tablist_aria_label).to eq "Tabs navigation"
    end
  end
end
