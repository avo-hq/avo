# frozen_string_literal: true

class Avo::ProfilePhotoComponent < ViewComponent::Base
  def initialize(profile_photo:)
    @profile_photo = profile_photo
  end

  def render?
    @profile_photo.present?
  end
end
