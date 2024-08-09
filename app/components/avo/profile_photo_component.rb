# frozen_string_literal: true

class Avo::ProfilePhotoComponent < Avo::BaseComponent
  prop :profile_photo, _Nilable(Avo::ProfilePhoto)

  def render?
    @profile_photo.present? && @profile_photo.visible_in_current_view?
  end
end
