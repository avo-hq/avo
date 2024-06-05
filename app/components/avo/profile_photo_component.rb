# frozen_string_literal: true

class Avo::ProfilePhotoComponent < ViewComponent::Base
  def initialize(profile_photo:)
    @profile_photo = profile_photo
  end

  def render?
    @profile_photo.present? && @profile_photo.visible_in_current_view?
  end
end
