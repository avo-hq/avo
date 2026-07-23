require "rails_helper"

RSpec.feature "i18n", type: :feature do
  let(:user) { User.first }
  let!(:post) { create :post, user: user }

  # These fixtures carry internal capitals on purpose. `.humanize` would render
  # "Payment Intent ID" as "Payment intent id" and `.capitalize` would render
  # "API People" as "Api people", so any surface that still casts a resolved
  # translation fails the examples below.
  around do |example|
    I18n.with_locale(:en) do
      I18n.backend.store_translations(
        :en,
        avo: {
          field_translations: {
            payment_intent_id: {
              one: "Payment Intent ID",
              other: "Payment Intent IDs"
            },
            people: {
              one: "API Person",
              other: "API People"
            }
          },
          resource_translations: {
            product: {
              one: "API Product",
              other: "API Products"
            }
          }
        }
      )

      example.run
    end
  ensure
    I18n.backend.reload!
  end

  describe "field translation_key" do
    it "uses a translated field name verbatim" do
      field = Avo::Fields::BaseField.new(:payment_intent_id)

      expect(field.name).to eq "Payment Intent ID"
      expect(field.plural_name).to eq "Payment Intent IDs"
    end

    it "humanizes the generated fallback when no translation resolves" do
      field = Avo::Fields::BaseField.new(:missing_field_name)

      expect(field.name).to eq "Missing field name"
      expect(field.sentence_name).to eq "missing field name"
    end

    it "uses a translated field name verbatim inside a sentence" do
      expect(Avo::Fields::BaseField.new(:payment_intent_id).sentence_name).to eq "Payment Intent ID"
    end

    # Field discovery assigns a name to every association field, so `name:` alone
    # does not mean a developer authored it. Those keep their previous lowercasing.
    it "lowercases a non-translated name inside a sentence" do
      field = Avo::Fields::BaseField.new(:main_post, name: "Main post")

      expect(field.sentence_name).to eq "main post"
    end

    it "uses a translated array field name verbatim" do
      expect(Avo::Fields::ArrayField.new(:people).name).to eq "API People"
    end

    describe "resource index (has_many)" do
      it "translation on the panel title" do
        visit "/admin/resources/users/#{user.id}/people?turbo_frame=has_many_field_show_people"

        expect(find('[data-component-name="avo/ui/panel_component"] .header__text').text).to eq "API People"
      end
    end

    describe "resource-scoped field translations" do
      it "uses the resource-scoped translation with shared fallback" do
        visit avo.new_resources_product_path

        expect(page).to have_text("Product title")
      end
    end
  end

  describe "save button" do
    it "have custom text" do
      visit avo.new_resources_product_path

      expect(page).to have_button("Save the product!")
    end

    it "uses a translated save label verbatim" do
      I18n.backend.store_translations(
        :en,
        avo: {resource_translations: {product: {save: "Save API credentials"}}}
      )

      visit avo.new_resources_product_path

      expect(page).to have_button("Save API credentials")
    end
  end

  describe "resource translation_key" do
    it "uses translated resource names verbatim" do
      expect(Avo::Resources::Product.name).to eq "API Product"
      expect(Avo::Resources::Product.plural_name).to eq "API Products"
      expect(Avo::Resources::Product.navigation_label).to eq "API Products"
      expect(Avo::Resources::Product.sentence_name).to eq "API Product"
    end

    it "humanizes the generated fallback when no translation resolves" do
      expect(Avo::Resources::Course.name).to eq "Course"
      expect(Avo::Resources::Course.plural_name).to eq "Courses"
      expect(Avo::Resources::Course.sentence_name).to eq "course"
    end

    it "renders translated resource names in breadcrumbs and navigation" do
      visit avo.resources_products_path

      expect(find(".breadcrumbs").text).to include "API Products"
      expect(page).to have_css(".avo-sidebar", text: "API Products")
    end

    it "interpolates the translated resource name into the new-page heading" do
      visit avo.new_resources_product_path

      expect(page).to have_text("Create new API Product")
    end

    it "still capitalizes Avo's own chrome strings" do
      visit avo.new_resources_product_path

      expect(find(".breadcrumbs").text).to include "New"
    end

    it "apply translation_key" do
      visit avo.resources_courses_path(force_locale: :pt)

      # The pt fixture defines `curso`/`cursos` in lowercase. Avo used to
      # capitalize that for display; it is now rendered as written.
      expect(page).to have_text("cursos")
      expect(page).to have_text("Criar novo curso")
    end
  end
end
