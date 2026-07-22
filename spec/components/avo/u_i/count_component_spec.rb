# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::CountComponent, type: :component do
  include Capybara::RSpecMatchers

  def render_component(**)
    render_inline(described_class.new(**))
  end

  describe "rendering" do
    it "renders the count as the visible text" do
      render_component(count: "1,234")

      expect(page).to have_css("span.count", text: "1,234")
    end

    it "forwards custom classes" do
      render_component(count: "5", classes: "ms-1")

      expect(page).to have_css("span.count.ms-1")
    end

    it "forwards data attributes" do
      render_component(count: "5", data: {testid: "count"})

      expect(page).to have_css("span.count[data-testid='count']")
    end
  end

  describe "with a label (accessible name)" do
    it "does not raise when passed a label keyword" do
      expect { render_component(count: "5", label: "5 records") }.not_to raise_error
    end

    it "renders the label as the aria-label while count stays the visible text" do
      render_component(count: "1,234", label: "1234 records")

      expect(page).to have_css("span.count[aria-label='1234 records']", text: "1,234")
    end

    it "omits aria-label when no label is given" do
      render_component(count: "5")

      expect(page).not_to have_css("span.count[aria-label]")
    end
  end
end
