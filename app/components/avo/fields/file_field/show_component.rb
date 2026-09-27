# frozen_string_literal: true

class Avo::Fields::FileField::ShowComponent < Avo::Fields::ShowComponent
  def lightbox?
    @field.lightbox_for?(@field.value)
  end
end
