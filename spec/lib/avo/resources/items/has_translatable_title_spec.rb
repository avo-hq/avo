require "rails_helper"

RSpec.describe Avo::Concerns::HasTranslatableTitle, type: :model do
  let(:record) { Struct.new(:name).new("Invoice 123") }
  let(:resource) { double(translation_key: "avo.resource_translations.invoice", record:) }

  around do |example|
    I18n.backend.store_translations(
      :en,
      {
        avo: {
          resource_translations: {
            invoice: {
              tabs: {
                payment_history: "Payment history",
                localized_fallback: "VAT & API history"
              },
              panels: {
                payment_history: "Payment details",
                localized_fallback: "VAT & API details"
              }
            }
          }
        },
        custom: {
          layout_title: "Custom layout title"
        }
      }
    )
    I18n.backend.store_translations(
      :pt,
      {
        avo: {
          resource_translations: {
            invoice: {
              tabs: {
                payment_history: "Histórico de pagamentos"
              },
              panels: {
                payment_history: "Detalhes do pagamento"
              }
            }
          }
        }
      }
    )

    I18n.with_locale(:en) { example.run }
  ensure
    I18n.backend.reload!
  end

  shared_examples "a resource-translated title" do |item_class, scope, english_title, portuguese_title|
    def build_item(item_class, **args)
      item_class.new(**args).hydrate(resource:, view: :show)
    end

    it "derives a predictable key from the resource and fallback title" do
      item = build_item(item_class, title: "Payment history")

      expect(item.translation_key).to eq "avo.resource_translations.invoice.#{scope}.payment_history"
    end

    it "resolves the title in the current request locale" do
      item = build_item(item_class, title: "Payment history")

      expect(I18n.with_locale(:en) { item.title }).to eq english_title
      expect(I18n.with_locale(:pt) { item.title }).to eq portuguese_title
    end

    it "uses the configured title when the generated key is missing" do
      item = build_item(item_class, title: "Untranslated title")

      expect(item.title).to eq "Untranslated title"
    end

    it "trusts the translated title casing and punctuation" do
      item = build_item(item_class, title: "Localized fallback")

      expect(item.title).to eq(scope == "tabs" ? "VAT & API history" : "VAT & API details")
    end

    it "supports a full translation_key override" do
      item = build_item(item_class, title: "Fallback title", translation_key: "custom.layout_title")

      expect(item.translation_key).to eq "custom.layout_title"
      expect(item.title).to eq "Custom layout title"
    end

    it "evaluates callable fallbacks with the hydrated resource context" do
      item = build_item(item_class, title: -> { resource.record.name })

      expect(item.title).to eq "Invoice 123"
    end
  end

  include_examples(
    "a resource-translated title",
    Avo::Resources::Items::Tab,
    "tabs",
    "Payment history",
    "Histórico de pagamentos"
  )

  include_examples(
    "a resource-translated title",
    Avo::Resources::Items::Panel,
    "panels",
    "Payment details",
    "Detalhes do pagamento"
  )
end
