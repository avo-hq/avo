# frozen_string_literal: true

class Avo::DiscreetInformationComponent < Avo::BaseComponent
  prop :payload

  def items
    @payload.items.compact
  end
end
