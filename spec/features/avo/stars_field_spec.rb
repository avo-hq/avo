require "rails_helper"

RSpec.feature "Stars Debug", type: :feature do
  let(:product) { create :product }

  describe "when rating is nil" do
    context "new" do
      it "displays 5 unfilled stars on the new page" do
        Avo::Resources::Product.with_temporary_items do
          field :rating, as: :stars
        end
  
        visit avo.new_resources_product_path
        expect(page).to have_css("[data-controller='stars-field']")
        expect(page).to have_css(".star", count: 5)
        expect(page).to have_css(".star.filled", count: 0)
  
        Avo::Resources::Product.restore_items_from_backup
      end
    end

    context "edit" do
      let(:product) { create :product, rating: 0 }

      it "displays 5 unfilled stars on the edit page of a product without a rating" do

        Avo::Resources::Product.with_temporary_items do
          field :rating, as: :stars
        end
  
        visit avo.edit_resources_product_path product
        expect(page).to have_css("[data-controller='stars-field']")
        expect(page).to have_css(".star", count: 5)
        expect(page).to have_css(".star.filled", count: 0)
  
        Avo::Resources::Product.restore_items_from_backup
      end
    end
  end

  describe "when rating is set to a value" do

    context "new" do
      it "creates a new rating for a product by clicking and shows the right number of stars selected on the show page" do
        visit avo.new_resources_product_path

        expect(page).to have_css(".star.filled", count: 0)
        
        #problem is with this line below
        find(".star[data-star-value='4']").click
        #problem is with this line above:to use or not to use JS
          
        expect(page).to have_css(".star.filled", count: 4)

        fill_in "product_title", with: "Test Product"

        click_button "Save"
      end
    end

    context "edit" do
      let(:product) { create :product, rating: 2 }

      it "allows the rating of a product to be changed and displays the correct new rating on the show page" do
        visit avo.edit_resources_product_path product
           
        expect(page).to have_css(".star.filled", count: 2)

        find("[data-star-value='5']").click

        expect(page).to have_css(".star.filled", count: 5)

        click_button "Save"
      end
    end
  end
end

