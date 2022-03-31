# frozen_string_literal: true

class Avo::Fields::FileField::IndexComponent < Avo::Fields::IndexComponent
  def flush?
    has_image_tag? || has_audio_tag?
  end

  def has_image_tag?
    @field.value.attached? && @field.value.representable? && @field.is_image
  end

  def has_audio_tag?
    @field.value.attached? && @field.is_audio
  end
end
