# frozen_string_literal: true

class Avo::Fields::Common::BooleanGroupComponent < Avo::BaseComponent
  prop :options, Hash, default: {}.freeze
  prop :value, _Nilable(Hash)
end
