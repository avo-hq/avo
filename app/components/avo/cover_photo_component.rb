# frozen_string_literal: true

class Avo::CoverPhotoComponent < ViewComponent::Base
  def initialize(cover_photo:, size:)
    @cover_photo = cover_photo
    @size = size
  end

  # aspect-cover-sm
  # aspect-cover-md
  # aspect-cover-lg
  def size_class
    "aspect-cover-#{@size}"
  end

  def render?
    @cover_photo.present?
  end
end
