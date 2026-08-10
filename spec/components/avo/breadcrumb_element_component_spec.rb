require "rails_helper"

RSpec.describe Avo::BreadcrumbElementComponent, type: :component do
  describe "resource color on the initials chip" do
    it "adds the palette modifier to the element" do
      render_inline described_class.new(text: "Users", initials: "U", color: :purple, avatar: nil)

      expect(page).to have_css ".breadcrumb-element.breadcrumb-element--color-purple .cado-avatar--initials"
    end

    it "accepts string values" do
      render_inline described_class.new(text: "Users", initials: "U", color: "teal", avatar: nil)

      expect(page).to have_css ".breadcrumb-element--color-teal"
    end

    it "renders no modifier without a color" do
      render_inline described_class.new(text: "Users", initials: "U", avatar: nil)

      expect(page).not_to have_css "[class*='breadcrumb-element--color-']"
    end

    it "renders no modifier for an unknown color" do
      render_inline described_class.new(text: "Users", initials: "U", color: :bogus, avatar: nil)

      expect(page).not_to have_css "[class*='breadcrumb-element--color-']"
    end
  end
end
