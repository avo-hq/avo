# frozen_string_literal: true

class Avo::DividerComponent < Avo::BaseComponent
  attr_reader :label

  def initialize(label = nil, **args)
    @label = label
  end
end
