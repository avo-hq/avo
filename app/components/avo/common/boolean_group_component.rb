# frozen_string_literal: true

class Avo::Common::BooleanGroupComponent < ViewComponent::Base
  def initialize(options: {}, value: nil)
    @options = options
    @value = value
  end
end
