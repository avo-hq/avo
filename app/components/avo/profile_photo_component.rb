# frozen_string_literal: true

class Avo::ProfilePhotoComponent < Avo::BaseComponent
  prop :profile_photo

  def render?
    @profile_photo.present? && @profile_photo.visible_in_current_view?
  end

  def extra_classes
    classes = []

    classes << "object-#{object_fit}" if object_fit.present?
    classes << "p-#{@profile_photo.options[:padding]}" if @profile_photo.options[:padding]

    classes.join(" ")
  end

  def object_fit
    @profile_photo.options[:object_fit] || :cover
  end
end
