# frozen_string_literal: true

class Avo::Fields::Common::DelegatedTypeComponent < ViewComponent::Base
  def initialize(field:, parent_component:)
    @field = field
    @parent_component = parent_component
  end

  delegate :field_wrapper_args, to: :@parent_component
end
