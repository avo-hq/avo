# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::Fields::BaseField, "field-adjacent i18n" do
  let(:translations) do
    {
      en: {
        avo: {
          field_translations: {
            dates: {
              one: "Date range",
              other: "Date ranges",
              help: "EN Help",
              placeholder: "EN Placeholder",
              include_blank: "EN Blank"
            }
          },
          resource_translations: {
            import_guesty: {
              fields: {
                dates: {
                  help: "EN Resource help",
                  placeholder: "EN Resource placeholder",
                  include_blank: "EN Resource blank"
                }
              }
            }
          }
        }
      },
      de: {
        avo: {
          field_translations: {
            dates: {
              one: "Datumsbereich",
              other: "Datumsbereiche",
              help: "DE Help",
              placeholder: "DE Placeholder",
              include_blank: "DE Blank"
            }
          }
        }
      }
    }
  end

  around do |example|
    I18n.backend.store_translations(:en, translations[:en])
    I18n.backend.store_translations(:de, translations[:de])
    example.run
  ensure
    I18n.backend.reload!
  end

  def text_field(**args)
    Avo::Fields::TextField.new(:dates, **args)
  end

  def select_field(**args)
    Avo::Fields::SelectField.new(:dates, options: {a: "A"}, **args)
  end

  describe "#help" do
    it "resolves help from translation_key when no explicit help is given" do
      field = text_field

      I18n.with_locale(:en) { expect(field.help).to eq "EN Help" }
      I18n.with_locale(:de) { expect(field.help).to eq "DE Help" }
    end

    it "prefers an explicit help option over translations" do
      field = text_field(help: "Explicit help")

      expect(field.help).to eq "Explicit help"
    end

    it "supports a custom translation_key under resource_translations" do
      field = text_field(translation_key: "avo.resource_translations.import_guesty.fields.dates")

      expect(field.help).to eq "EN Resource help"
    end

    it "returns nil when neither help nor a translation is present" do
      expect(Avo::Fields::TextField.new(:missing_field).help).to be_nil
    end
  end

  describe "#placeholder" do
    it "resolves placeholder from translation_key before falling back to the name" do
      field = text_field

      I18n.with_locale(:en) { expect(field.placeholder).to eq "EN Placeholder" }
      I18n.with_locale(:de) { expect(field.placeholder).to eq "DE Placeholder" }
    end

    it "prefers an explicit placeholder option over translations" do
      field = text_field(placeholder: "Explicit placeholder")

      expect(field.placeholder).to eq "Explicit placeholder"
    end

    it "falls back to the field name when no placeholder translation exists" do
      field = Avo::Fields::TextField.new(:missing_field, name: "Missing field")

      expect(field.placeholder).to eq "Missing field"
    end

    it "lets select fields use a translated placeholder before choose_an_option" do
      field = select_field

      I18n.with_locale(:en) { expect(field.placeholder).to eq "EN Placeholder" }
    end

    it "keeps choose_an_option as the select default when no translation exists" do
      field = Avo::Fields::SelectField.new(:missing_field, options: {a: "A"})

      expect(field.placeholder).to eq I18n.t("avo.choose_an_option")
    end

    it "lets has_one (frame) fields use a translated placeholder before choose_an_option" do
      field = Avo::Fields::HasOneField.new(:dates)

      I18n.with_locale(:en) { expect(field.placeholder).to eq "EN Placeholder" }
    end

    it "keeps choose_an_option as the has_one default when no translation exists" do
      field = Avo::Fields::HasOneField.new(:missing_field)

      expect(field.placeholder).to eq I18n.t("avo.choose_an_option")
    end
  end

  describe "#include_blank" do
    it "resolves include_blank from translation_key when the option is omitted" do
      field = select_field

      I18n.with_locale(:en) { expect(field.include_blank).to eq "EN Blank" }
      I18n.with_locale(:de) { expect(field.include_blank).to eq "DE Blank" }
    end

    it "prefers an explicit include_blank string over translations" do
      field = select_field(include_blank: "Explicit blank")

      expect(field.include_blank).to eq "Explicit blank"
    end

    it "keeps include_blank: false" do
      field = select_field(include_blank: false)

      expect(field.include_blank).to be false
    end

    it "uses the placeholder when include_blank: true" do
      field = select_field(include_blank: true)

      expect(field.include_blank).to eq "EN Placeholder"
    end
  end
end
