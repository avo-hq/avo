require "rails_helper"

RSpec.feature "Localization spec", type: :feature do
  describe "force_locale" do
    it "translates the resource name on the create button" do
      visit avo.resources_products_path(force_locale: :pt)

      # The pt fixture defines the product name as "Produto", so it is used
      # verbatim -- the create button no longer downcases the first word.
      expect(page).to have_text "Criar novo Produto"
    end
  end
end
