# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabsComponent, type: :component do
  describe "rendering" do
    it "renders the tabs container with default variant" do
      render_inline(described_class.new)

      expect(page).to have_css("div.tabs.tabs--group")
      expect(page).to have_css("div[role='tablist']")
    end

    it "renders with the group variant by default" do
      render_inline(described_class.new)

      expect(page).to have_css(".tabs--group")
    end

    it "renders with the scope variant when specified" do
      render_inline(described_class.new(variant: :scope))

      expect(page).to have_css(".tabs--scope")
    end

    it "renders with custom id" do
      render_inline(described_class.new(id: "custom-tabs"))

      expect(page).to have_css("div#custom-tabs")
    end

    it "uses generated id when not provided" do
      render_inline(described_class.new)

      expect(page).to have_css("div[id^='tabs-']")
    end

    it "renders with custom aria-label" do
      render_inline(described_class.new(aria_label: "Main Navigation"))

      expect(page).to have_css("div[aria-label='Main Navigation']")
    end

    it "uses default aria-label when not provided" do
      render_inline(described_class.new)

      expect(page).to have_css("div[aria-label='Tabs navigation']")
    end

    it "renders content block" do
      render_inline(described_class.new) do
        "<span class='tab-content'>Tab 1</span>".html_safe
      end

      expect(page).to have_css(".tab-content", text: "Tab 1")
    end
  end

  describe "#classes" do
    it "returns correct classes for group variant" do
      component = described_class.new(variant: :group)
      expect(component.classes).to eq "tabs tabs--group"
    end

    it "returns correct classes for scope variant" do
      component = described_class.new(variant: :scope)
      expect(component.classes).to eq "tabs tabs--scope"
    end
  end

  describe "#tablist_id" do
    it "returns custom id when provided" do
      component = described_class.new(id: "my-tabs")
      expect(component.tablist_id).to eq "my-tabs"
    end

    it "generates an id when not provided" do
      component = described_class.new
      expect(component.tablist_id).to start_with("tabs-")
    end
  end

  describe "#tablist_aria_label" do
    it "returns custom aria-label when provided" do
      component = described_class.new(aria_label: "Custom Label")
      expect(component.tablist_aria_label).to eq "Custom Label"
    end

    it "returns default aria-label when not provided" do
      component = described_class.new
      expect(component.tablist_aria_label).to eq "Tabs navigation"
    end
  end

  # CSS class structure tests based on tabs.css
  describe "CSS class structure" do
    describe "base styles (.tabs)" do
      it "applies the base .tabs class" do
        render_inline(described_class.new)

        expect(page).to have_css(".tabs")
      end
    end

    describe "group variant CSS (.tabs--group)" do
      it "applies .tabs--group for flex container with gap" do
        render_inline(described_class.new(variant: :group))

        expect(page).to have_css(".tabs.tabs--group")
      end
    end

    describe "scope variant CSS (.tabs--scope)" do
      it "applies .tabs--scope class" do
        render_inline(described_class.new(variant: :scope))

        expect(page).to have_css(".tabs.tabs--scope")
      end
    end
  end
end
