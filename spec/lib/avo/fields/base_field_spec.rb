require "rails_helper"

RSpec.describe Avo::Fields::BaseField, type: :model do
  let(:product_resource) { Avo::Resources::Product.new(view: Avo::ViewInquirer.new(:show)) }

  def build_field(id, **args)
    described_class.new(id, **args).hydrate(resource: product_resource, view: Avo::ViewInquirer.new(:show))
  end

  describe "#translation_key" do
    it "returns the resource-scoped key by default when a resource is present" do
      field = build_field(:title)

      expect(field.translation_key).to eq "avo.resource_translations.product.fields.title"
    end

    it "returns the shared key when no resource is present" do
      field = described_class.new(:title)

      expect(field.translation_key).to eq "avo.field_translations.title"
    end

    it "returns an explicit translation_key when provided" do
      field = build_field(:title, translation_key: "custom.translation.key")

      expect(field.translation_key).to eq "custom.translation.key"
    end
  end

  describe "#shared_translation_key" do
    it "returns the shared field translation key" do
      field = build_field(:title)

      expect(field.shared_translation_key).to eq "avo.field_translations.title"
    end
  end

  describe "#resource_scoped_translation_key" do
    it "returns the resource-scoped field translation key" do
      field = build_field(:title)

      expect(field.resource_scoped_translation_key).to eq "avo.resource_translations.product.fields.title"
    end

    it "returns nil when no resource is present" do
      field = described_class.new(:title)

      expect(field.resource_scoped_translation_key).to be_nil
    end
  end

  describe "#name" do
    around do |example|
      I18n.with_locale(:en) do
        I18n.backend.store_translations(
          :en,
          avo: {
            resource_translations: {
              product: {
                fields: {
                  title: {
                    one: "Product title",
                    other: "Product titles"
                  }
                }
              }
            },
            field_translations: {
              title: {
                one: "Title",
                other: "Titles"
              }
            }
          }
        )

        example.run
      end
    end

    it "prefers the resource-scoped translation" do
      field = build_field(:title)

      expect(field.name).to eq "Product title"
    end

    it "falls back to the shared field translation" do
      I18n.backend.store_translations(
        :en,
        avo: {
          resource_translations: {
            product: {
              fields: {}
            }
          },
          field_translations: {
            description: {
              one: "Description",
              other: "Descriptions"
            }
          }
        }
      )

      field = build_field(:description)

      expect(field.name).to eq "Description"
    end

    it "skips a resource-scoped key with invalid pluralization data and uses the shared fallback" do
      I18n.backend.store_translations(
        :en,
        avo: {
          resource_translations: {
            product: {
              fields: {
                subtitle: {
                  other: "Product subtitles"
                }
              }
            }
          },
          field_translations: {
            subtitle: {
              one: "Subtitle",
              other: "Subtitles"
            }
          }
        }
      )

      field = build_field(:subtitle)

      expect(field.name).to eq "Subtitle"
    end

    it "falls back to the humanized field id when no translations exist" do
      field = build_field(:sku_code)

      expect(field.name).to eq "Sku code"
    end

    it "uses an explicit translation_key without resource or shared fallbacks" do
      I18n.backend.store_translations(
        :en,
        custom: {
          field: {
            one: "Custom label",
            other: "Custom labels"
          }
        }
      )

      field = build_field(:title, translation_key: "custom.field")

      expect(field.name).to eq "Custom label"
    end
  end

  describe "#plural_name" do
    around do |example|
      I18n.with_locale(:en) do
        I18n.backend.store_translations(
          :en,
          avo: {
            resource_translations: {
              product: {
                fields: {
                  title: {
                    one: "Product title",
                    other: "Product titles"
                  }
                }
              }
            },
            field_translations: {
              title: {
                one: "Title",
                other: "Titles"
              }
            }
          }
        )

        example.run
      end
    end

    it "prefers the resource-scoped plural translation" do
      field = build_field(:title)

      expect(field.plural_name).to eq "Product titles"
    end

    it "falls back to the shared plural field translation" do
      I18n.backend.store_translations(
        :en,
        avo: {
          resource_translations: {
            product: {
              fields: {}
            }
          },
          field_translations: {
            description: {
              one: "Description",
              other: "Descriptions"
            }
          }
        }
      )

      field = build_field(:description)

      expect(field.plural_name).to eq "Descriptions"
    end
  end
end
