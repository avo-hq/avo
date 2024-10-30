# frozen_string_literal: true

class Avo::CoverPhotoComponent < Avo::BaseComponent
  prop :cover_photo
  prop :size do |value|
    @cover_photo&.size
  end

  # aspect-cover-sm
  # aspect-cover-md
  # aspect-cover-lg
  def size_class
    "aspect-cover-#{@size}"
  end

  def render?
    @cover_photo.present? && @cover_photo.visible_in_current_view?
  end
end
