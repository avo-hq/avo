# frozen_string_literal: true

class Avo::UI::TextInputComponent < Avo::BaseComponent
  prop :label
  prop :value
  prop :name
  prop :id
  prop :autocomplete, default: :off
  prop :aria_label
  prop :classes
  prop :type, default: "text"
  prop :data, default: -> { {} }
  prop :placeholder
  prop :disabled, default: false
  prop :readonly, default: false
  prop :hint
  prop :error, default: false
  prop :error_message
  prop :loading, default: false

  def computed_classes
    class_names(
      "text-input",
      @classes,
      {
        "text-input--disabled": @disabled,
        "text-input--read-only": @readonly,
        "text-input--error": @error,
        "text-input--loading": @loading
      }
    )
  end

  def show_hint?
    @hint.present? && !@error && !@readonly
  end
end
