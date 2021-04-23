# frozen_string_literal: true

class Avo::Fields::Common::BooleanGroupComponent < ViewComponent::Base
  def initialize(options: {}, value: nil)
    @options = options
    @value = value
  end
end
