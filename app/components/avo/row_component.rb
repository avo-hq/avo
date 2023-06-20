# frozen_string_literal: true

class Avo::RowComponent < ViewComponent::Base
  attr_reader :classes

  renders_one :body

  def initialize(classes: nil, data: {})
    @classes = classes
    @data = data
  end
end
