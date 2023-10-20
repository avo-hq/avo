# frozen_string_literal: true

class Avo::ModalComponent < ViewComponent::Base
  renders_one :heading
  renders_one :controls

  attr_reader :width
  attr_reader :body_class

  def initialize(width: :md, body_class: nil)
    @width = width
    @body_class = body_class
  end

  def width_classes
    case width.to_sym
    when :md
      "w-11/12 lg:w-1/2 sm:max-w-168"
    when :xl
      "w-11/12 lg:w-3/4"
    end
  end

  def height_classes
    "max-h-full min-h-1/4 max-h-11/12"
  end
end
