# frozen_string_literal: true

class Avo::Fields::Common::BooleanGroupComponent < Avo::BaseComponent
  prop :options, Hash, default: {}.freeze
  prop :value, _Nilable(Hash)

  def checked(id)
    @value.present? && @value.with_indifferent_access[id].present?
  end
end
