# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::UI::Tabs::TabsComponent, type: :component do
  subject(:component) { described_class.new(**options) }

  let(:options) { {} }

  describe "rendering" do
    it "renders the tabs container with proper attributes" do
      render_inline(component)

      expect(page).to have_css("div.tabs")
      expect(page).to have_css("div[role='tablist']")
      expect(page).to have_css("div[aria-label='Tabs navigation']")
      expect(page).to have_css("div[id^='tabs-']")
    end

    context "with custom attributes" do
      let(:options) { {id: "custom-tabs", aria_label: "Main Navigation"} }

      it "renders with custom id and aria-label" do
        render_inline(component)

        expect(page).to have_css("div#custom-tabs")
        expect(page).to have_css("div[aria-label='Main Navigation']")
      end
    end

    it "renders content block" do
      render_inline(component) do
        "<span class='tab-content'>Tab 1</span>".html_safe
      end

      expect(page).to have_css(".tab-content", text: "Tab 1")
    end
  end

  describe "#tablist_id" do
    subject { component.tablist_id }

    context "when id is provided" do
      let(:options) { {id: "my-tabs"} }
      it { is_expected.to eq "my-tabs" }
    end

    context "when id is not provided" do
      it { is_expected.to start_with("tabs-") }
    end
  end

  describe "#tablist_aria_label" do
    subject { component.tablist_aria_label }

    context "when aria_label is provided" do
      let(:options) { {aria_label: "Custom Label"} }
      it { is_expected.to eq "Custom Label" }
    end

    context "when aria_label is not provided" do
      it { is_expected.to eq "Tabs navigation" }
    end
  end
end
