# frozen_string_literal: true

class Avo::ComponentMissingComponent < ViewComponent::Base
  def initialize(*args, component_name:, &block)
    @component_name = component_name
  end

  def call
    "Component #{@component_name} not found in the Cado catalog."
  end
end
