# frozen_string_literal: true

class Avo::Fields::Common::BooleanGroupComponent < Avo::BaseComponent
  prop :options, default: {}.freeze
  prop :value
end
