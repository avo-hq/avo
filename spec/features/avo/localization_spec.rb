require "rails_helper"

RSpec.feature "Localization spec", type: :feature do
  describe "force_locale" do
    it "translates the resource name on the create button" do
      visit avo.resources_products_path(force_locale: :pt)

      expect(page).to have_text "Criar novo produto"
    end
  end
end
