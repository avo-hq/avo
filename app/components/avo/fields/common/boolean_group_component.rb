# frozen_string_literal: true

class Avo::Fields::Common::BooleanGroupComponent < Avo::BaseComponent
  def initialize(options: {}, value: nil)
    @options = options
    @value = value
  end
end
