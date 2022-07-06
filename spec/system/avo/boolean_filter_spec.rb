require "rails_helper"

RSpec.describe "Filters", type: :system do
  describe "Boolean filter without default" do
    let!(:featured_post) { create :post, name: "Featured post", is_featured: true, published_at: nil }
    let!(:unfeatured_post) { create :post, name: "Unfeatured post", is_featured: false, published_at: nil }

    let(:url) { "/admin/resources/posts?view_type=table" }

    it "allows selecting and deselecting all" do
      visit url
      expect(page.all("input[name='Select item']").any?(&:checked?)).to be false

      check("Select all on page")

      expect(page.all("input[name='Select item']").all?(&:checked?)).to be true

      uncheck("Select item", match: :first)
      expect(page.all("input[name='Select item']").map(&:checked?)).to match_array([false, true])

      expect(page.find("input[name='Select all on page']")).not_to be_checked
    end
  end
end
