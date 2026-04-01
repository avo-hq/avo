require "rails_helper"

RSpec.feature "Stars Field", type: :system do
  before(:each) do
    Avo::Resources::Product.with_temporary_items do
      field :rating, as: :stars
    end
  end

  after(:each) do
    Avo::Resources::Product.restore_items_from_backup
  end

  describe "star field interactions" do
    it "displays unfilled stars for products without ratings" do
      product = create(:product, rating: 0)

      visit avo.edit_resources_product_path(product)
      expect(page).to have_css("[data-controller='stars-field']")
      expect(page).to have_css(".star", count: 5)
      expect(page).to have_css(".star.filled", count: 0)
    end

    it "allows setting rating via star clicks and persists the data" do
      # Creates new product with rating
      visit avo.new_resources_product_path

      expect(page).to have_css(".star.filled", count: 0)
      find(".star[data-star-value='4']").click
      expect(page).to have_css(".star.filled", count: 4)

      click_button "Save"
      created_product = Product.last
      expect(created_product.rating).to eq(4)

      # Verify show page of newly created product displays correct rating of 4
      visit avo.resources_product_path(created_product)
      expect(page).to have_css(".star.filled", count: 4)

      # Test editing existing product rating
      visit avo.edit_resources_product_path(created_product)
      expect(page).to have_css(".star.filled", count: 4)

      find(".star[data-star-value='2']").click
      expect(page).to have_css(".star.filled", count: 2)

      click_button "Save"
      created_product.reload
      expect(created_product.rating).to eq(2)

      # Verify updated rating on the product show page
      visit avo.resources_product_path(created_product)
      expect(page).to have_css(".star.filled", count: 2)
    end
  end
end
