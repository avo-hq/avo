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
