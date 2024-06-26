# frozen_string_literal: true

class Avo::RowSelectorComponent < Avo::BaseComponent
  SIZE = _Union(:md, :lg)

  prop :floating, _Boolean, default: false
  prop :size, SIZE, default: SIZE[:md]
end
