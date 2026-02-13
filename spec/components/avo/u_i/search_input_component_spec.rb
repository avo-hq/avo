# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::SearchInputComponent, type: :component do
  describe "rendering" do
    it "renders wrapper with search-input class" do
      render_inline(described_class.new(name: "q", placeholder: "Search"))

      expect(page).to have_css("div.search-input")
      expect(page).to have_css("input[type='search'][name='q'][placeholder='Search']")
    end

    it "passes data attributes to the input for resource-search controller" do
      render_inline(described_class.new(
        name: "q",
        data: {
          action: "input->resource-search#search",
          "resource-search-target": "input"
        }
      ))

      input = page.find("input[name='q']")
      expect(input["data-resource-search-target"]).to eq("input")
      expect(input["data-action"]).to eq("input->resource-search#search")
    end

    it "renders search icon prefix" do
      render_inline(described_class.new(name: "q"))

      expect(page).to have_css(".search-input__prefix")
      expect(page).to have_css(".search-input__prefix svg")
    end

    it "renders shortcut suffix when with_shortcut is true" do
      render_inline(described_class.new(name: "q", with_shortcut: true))

      expect(page).to have_css(".search-input__suffix")
      expect(page).to have_css(".search-input__shortcut", count: 2)
    end

    it "does not render shortcut suffix when with_shortcut is false" do
      render_inline(described_class.new(name: "q", with_shortcut: false))

      expect(page).not_to have_css(".search-input__suffix")
    end

    it "renders with value when provided" do
      render_inline(described_class.new(name: "q", value: "hello"))

      expect(page).to have_css("input[name='q'][value='hello']")
    end
  end
end
