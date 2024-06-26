# frozen_string_literal: true

class Avo::ModalComponent < Avo::BaseComponent
  SIZE = _Union(:md, :xl)

  prop :width, SIZE, default: SIZE[:md]
  prop :body_class, _Nilable(String)

  renders_one :heading
  renders_one :controls

  def width_classes
    case @width
    in :md
      "w-11/12 lg:w-1/2 sm:max-w-168"
    in :xl
      "w-11/12 lg:w-3/4"
    end
  end

  def height_classes
    "max-h-full min-h-1/4 max-h-11/12"
  end
end
