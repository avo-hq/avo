# frozen_string_literal: true

class Avo::UI::RadioButtonComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :disabled, default: false
  prop :label
  prop :description
  prop :name
  prop :value
  prop :id
  prop :title
  prop :autocomplete, default: :off
  prop :data, default: -> { {} }
  prop :classes
end
