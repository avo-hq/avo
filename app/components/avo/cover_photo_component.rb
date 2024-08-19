# frozen_string_literal: true

class Avo::CoverPhotoComponent < Avo::BaseComponent
  prop :cover_photo, _Nilable(Avo::CoverPhoto)
  prop :size, _Nilable(Symbol) do |value|
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
