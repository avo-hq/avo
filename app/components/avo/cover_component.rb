# frozen_string_literal: true

class Avo::CoverComponent < Avo::BaseComponent
  prop :cover
  prop :size do |value|
    @cover&.size
  end

  def size_class
    case @size
    when :sm
      "max-h-60"
    when :md
      "max-h-100"
    when :lg
      "max-h-140"
    when :full
      "max-h-auto"
    end
  end

  def render?
    @cover.present? && @cover.visible_in_current_view?
  end
end
