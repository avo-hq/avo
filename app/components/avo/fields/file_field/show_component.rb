# frozen_string_literal: true

class Avo::Fields::FileField::ShowComponent < Avo::Fields::ShowComponent
  # The lightbox only has something to show for an attached image.
  def lightbox?
    @field.lightbox? && @field.value.attached? && @field.value.representable? && @field.value.image?
  rescue
    false
  end
end
