# frozen_string_literal: true

require "rails_helper"

RSpec.describe Avo::BaseAction, "default i18n labels" do
  let(:action_class) do
    Class.new(Avo::BaseAction) do
      self.name = "Locale probe"
    end
  end

  def labels_for(locale)
    I18n.with_locale(locale) do
      action = action_class.new
      {
        message: action.get_message,
        confirm: action.confirm_button_label,
        cancel: action.cancel_button_label
      }
    end
  end

  it "resolves default message and button labels in the current locale each time" do
    english = labels_for(:en)
    german = labels_for(:de)

    expect(english).to eq(
      message: I18n.t("avo.are_you_sure_you_want_to_run_this_option", locale: :en),
      confirm: I18n.t("avo.run", locale: :en),
      cancel: I18n.t("avo.cancel", locale: :en)
    )

    expect(german).to eq(
      message: I18n.t("avo.are_you_sure_you_want_to_run_this_option", locale: :de),
      confirm: I18n.t("avo.run", locale: :de),
      cancel: I18n.t("avo.cancel", locale: :de)
    )

    expect(german).not_to eq(english)
  end
end

RSpec.describe Avo::BaseAction, "action_translations" do
  let(:translations) do
    {
      en: {
        avo: {
          action_translations: {
            "locale_probe" => {
              name: "EN Name",
              message: "EN Message",
              confirm_button_label: "EN Confirm",
              cancel_button_label: "EN Cancel",
              description: "EN Description"
            },
            "city/update_probe" => {
              name: "EN City Update"
            }
          }
        }
      },
      de: {
        avo: {
          action_translations: {
            "locale_probe" => {
              name: "DE Name",
              message: "DE Message",
              confirm_button_label: "DE Confirm",
              cancel_button_label: "DE Cancel",
              description: "DE Description"
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

  describe ".translation_key" do
    it "derives the key from the action class name, namespace included" do
      stub_const("Avo::Actions::LocaleProbe", Class.new(Avo::BaseAction))
      stub_const("Avo::Actions::City::UpdateProbe", Class.new(Avo::BaseAction))

      expect(Avo::Actions::LocaleProbe.translation_key).to eq "avo.action_translations.locale_probe"
      expect(Avo::Actions::City::UpdateProbe.translation_key).to eq "avo.action_translations.city/update_probe"
    end

    it "respects an explicit self.translation_key override" do
      stub_const("Avo::Actions::LocaleProbe", Class.new(Avo::BaseAction) {
        self.translation_key = "avo.action_translations.custom_probe"
      })

      expect(Avo::Actions::LocaleProbe.translation_key).to eq "avo.action_translations.custom_probe"
    end
  end

  describe "translated attributes" do
    let(:action_class) do
      stub_const("Avo::Actions::LocaleProbe", Class.new(Avo::BaseAction) {
        self.name = "Class attribute name"
        self.message = "Class attribute message"
        self.confirm_button_label = "Class attribute confirm"
        self.cancel_button_label = "Class attribute cancel"
        self.description = "Class attribute description"
      })
    end

    def attributes_for(locale)
      I18n.with_locale(locale) do
        action = action_class.new
        {
          name: action.action_name,
          message: action.get_message,
          confirm: action.confirm_button_label,
          cancel: action.cancel_button_label,
          description: action.get_description
        }
      end
    end

    it "resolves name, message, button labels, and description from action_translations before class attributes" do
      expect(attributes_for(:en)).to eq(
        name: "EN Name",
        message: "EN Message",
        confirm: "EN Confirm",
        cancel: "EN Cancel",
        description: "EN Description"
      )

      expect(attributes_for(:de)).to eq(
        name: "DE Name",
        message: "DE Message",
        confirm: "DE Confirm",
        cancel: "DE Cancel",
        description: "DE Description"
      )
    end

    it "falls back to class attributes when no translation exists" do
      stub_const("Avo::Actions::MissingTranslationProbe", Class.new(Avo::BaseAction) {
        self.name = "Fallback name"
        self.message = "Fallback message"
        self.confirm_button_label = "Fallback confirm"
        self.cancel_button_label = "Fallback cancel"
        self.description = "Fallback description"
      })

      action = Avo::Actions::MissingTranslationProbe.new

      expect(action.action_name).to eq "Fallback name"
      expect(action.get_message).to eq "Fallback message"
      expect(action.confirm_button_label).to eq "Fallback confirm"
      expect(action.cancel_button_label).to eq "Fallback cancel"
      expect(action.get_description).to eq "Fallback description"
    end

    it "uses namespaced translation keys" do
      stub_const("Avo::Actions::City::UpdateProbe", Class.new(Avo::BaseAction) {
        self.name = "Update"
      })

      expect(Avo::Actions::City::UpdateProbe.new.action_name).to eq "EN City Update"
    end

    it "does not humanize resolved translations" do
      I18n.backend.store_translations(:en, {
        avo: {
          action_translations: {
            locale_probe: {
              name: "VAT Export"
            }
          }
        }
      })

      expect(action_class.new.action_name).to eq "VAT Export"
    end
  end
end
