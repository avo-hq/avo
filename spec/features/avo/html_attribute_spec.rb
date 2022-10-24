require "rails_helper"

RSpec.feature "HtmlAttributes", type: :feature do
  let(:product) { create :product }

  context "on show" do
    it "renders the html attributes" do
      visit avo.resources_product_path product

      expect(field_wrapper(:title).find('[data-slot="value"]')[:class]).to include "bg-gray-50 !text-pink-600"
      expect(field_wrapper(:title).find('[data-slot="label"]')[:class]).to include "bg-gray-50 !text-pink-600"
    end
  end
end
