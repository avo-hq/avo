# frozen_string_literal: true

class Avo::UI::FileUploadInputComponent < Avo::BaseComponent
  VALID_SIZES = %i[sm md lg].freeze unless defined?(VALID_SIZES)

  prop :id
  prop :title, default: "Click to upload"
  prop :subtitle, default: "or drag and drop"
  prop :description
  prop :size, default: :lg do |value|
    VALID_SIZES.include?(value) ? value : :lg
  end
  prop :disabled, default: false
  prop :classes
end
