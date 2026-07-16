require "rails_helper"

RSpec.describe "Field translation_key sibling options", type: :model do
  let(:view) { Avo::ViewInquirer.new(:new) }
  let(:base_translation_key) { "avo.resource_translations.import_guesty.fields" }

  before do
    I18n.backend.store_translations(:en, {
      avo: {
        resource_translations: {
          import_guesty: {
            fields: {
              dates: {
                help: "Optional. Standard period: 1 week ago to present.",
                placeholder: "Select date range"
              },
              status: {
                include_blank: "No status selected",
                placeholder: "Pick a status"
              },
              country: {
                placeholder: "Select a country"
              },
              author: {
                placeholder: "Pick an author"
              }
            }
          }
        }
      }
    })
  end

  describe Avo::Fields::TextField do
    it "falls back to sibling placeholder translation when placeholder is not provided" do
      field = described_class.new(:dates, translation_key: "#{base_translation_key}.dates")
        .hydrate(view:)

      expect(field.placeholder).to eq "Select date range"
    end

    it "falls back to sibling help translation when help is not provided" do
      field = described_class.new(:dates, translation_key: "#{base_translation_key}.dates")

      expect(field.help).to eq "Optional. Standard period: 1 week ago to present."
    end

    it "keeps explicit placeholder over sibling translation" do
      field = described_class.new(
        :dates,
        translation_key: "#{base_translation_key}.dates",
        placeholder: "Custom placeholder"
      ).hydrate(view:)

      expect(field.placeholder).to eq "Custom placeholder"
    end

    it "keeps explicit help over sibling translation" do
      field = described_class.new(
        :dates,
        translation_key: "#{base_translation_key}.dates",
        help: "Custom help"
      )

      expect(field.help).to eq "Custom help"
    end
  end

  describe Avo::Fields::SelectField do
    it "falls back to sibling placeholder translation when placeholder is not provided" do
      field = described_class.new(
        :status,
        options: {Draft: "draft"},
        translation_key: "#{base_translation_key}.status"
      ).hydrate(view:)

      expect(field.placeholder).to eq "Pick a status"
    end

    it "keeps the field default placeholder when sibling translation is missing" do
      field = described_class.new(
        :status,
        options: {Draft: "draft"},
        translation_key: "#{base_translation_key}.missing_status"
      ).hydrate(view:)

      expect(field.placeholder).to eq "Choose an option"
    end

    it "falls back to sibling include_blank translation when include_blank is not provided" do
      field = described_class.new(
        :status,
        options: {Draft: "draft"},
        translation_key: "#{base_translation_key}.status"
      ).hydrate(view:)

      expect(field.include_blank).to eq "No status selected"
    end

    it "evaluates callable include_blank values in field execution context" do
      field = described_class.new(
        :status,
        options: {Draft: "draft"},
        translation_key: "#{base_translation_key}.status",
        include_blank: -> { "Any status" }
      ).hydrate(view:)

      expect(field.include_blank).to eq "Any status"
    end
  end

  describe Avo::Fields::CountryField do
    it "falls back to sibling placeholder translation when placeholder is not provided" do
      field = described_class.new(:country, translation_key: "#{base_translation_key}.country")
        .hydrate(view:)

      expect(field.placeholder).to eq "Select a country"
    end
  end

  describe Avo::Fields::BelongsToField do
    it "falls back to sibling placeholder translation when placeholder is not provided" do
      field = described_class.new(:author, translation_key: "#{base_translation_key}.author")
        .hydrate(view:)

      expect(field.placeholder).to eq "Pick an author"
    end
  end
end
