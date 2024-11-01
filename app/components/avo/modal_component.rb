# frozen_string_literal: true

class Avo::ModalComponent < Avo::BaseComponent
  renders_one :heading
  renders_one :controls

  prop :width, default: :md
  prop :body_class
  prop :overflow, default: :auto

  def width_classes
    case @width.to_sym
    when :md
      "w-11/12 lg:w-1/2 sm:max-w-168"
    when :xl
      "w-11/12 lg:w-3/4"
    end
  end

  def height_classes
    "max-h-full min-h-1/4 max-h-11/12"
  end

  def overflow_classes
    @overflow == :auto ? "overflow-auto" : ""
  end
end
