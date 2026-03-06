# frozen_string_literal: true

class Avo::UI::SearchInputComponent < Avo::BaseComponent
  prop :name, default: "q"
  prop :id
  prop :value
  prop :placeholder
  prop :disabled, default: false
  prop :with_shortcut, default: false
  prop :classes
  prop :data, default: -> { {} }
end
