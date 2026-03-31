require "rails_helper"

RSpec.describe Avo::UI::DropdownCardComponent, type: :component do
  describe "rendering" do
    it "renders with header, body, and footer slots" do
      render_inline(described_class.new) do |c|
        c.with_header { "Header content" }
        c.with_body { "Body content" }
        c.with_footer { "Footer content" }
      end

      expect(page).to have_css(".dropdown-card")
      expect(page).to have_css(".dropdown-card", text: /Header content/)
      expect(page).to have_css(".dropdown-card__body", text: "Body content")
      expect(page).to have_css(".dropdown-card", text: /Footer content/)
    end

    it "renders without header and footer when those slots are not provided" do
      render_inline(described_class.new) do |c|
        c.with_body { "Only body" }
      end

      expect(page).to have_css(".dropdown-card")
      expect(page).to have_css(".dropdown-card__body", text: "Only body")
    end

    it "renders with header and body only" do
      render_inline(described_class.new) do |c|
        c.with_header { "Header only" }
        c.with_body { "Body content" }
      end

      expect(page).to have_css(".dropdown-card", text: /Header only/)
      expect(page).to have_css(".dropdown-card__body", text: "Body content")
    end

    it "renders with footer and body only" do
      render_inline(described_class.new) do |c|
        c.with_body { "Body content" }
        c.with_footer { "Footer only" }
      end

      expect(page).to have_css(".dropdown-card__body", text: "Body content")
      expect(page).to have_css(".dropdown-card", text: /Footer only/)
    end

    it "applies extra classes via the classes prop" do
      render_inline(described_class.new(classes: "custom-class")) do |c|
        c.with_body { "Content" }
      end

      expect(page).to have_css(".dropdown-card.custom-class")
    end
  end
end
