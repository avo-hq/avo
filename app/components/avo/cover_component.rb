# frozen_string_literal: true

class Avo::CoverComponent < Avo::BaseComponent
  prop :cover
  prop :size do |value|
    @cover&.size
  end

  # aspect-cover-sm
  # aspect-cover-md
  # aspect-cover-lg
  def size_class
    "aspect-cover-#{@size}"
  end

  def render?
    @cover.present? && @cover.visible_in_current_view?
  end
end
