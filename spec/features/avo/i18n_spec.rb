require "rails_helper"

RSpec.feature "i18n", type: :feature do
  let(:user) { User.first }
  let!(:post) { create :post, user: user }

  describe "field translation_key" do
    describe "resource index (has_many)" do
      it "translation on the panel title" do
        visit "/admin/resources/users/#{user.id}/people?turbo_frame=has_many_field_show_people"

        expect(find("[data-target='title']").text).to eq "People"
      end
    end
  end

  describe "save button" do
    it "have custom text" do
      visit avo.new_resources_product_path

      expect(page).to have_button("Save the product!")
    end
  end

  describe "resource translation_key" do
    it "apply translation_key" do
      visit avo.resources_courses_path(force_locale: :pt)

      expect(page).to have_text("Cursos")
      expect(page).to have_text("Criar novo curso")
    end
  end
end
