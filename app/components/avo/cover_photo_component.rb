# frozen_string_literal: true

class Avo::CoverPhotoComponent < ViewComponent::Base
  extend Dry::Initializer

  option :resource, optional: true

  def cover_photo
    resource.record.cover_photo
  end

  def profile_photo
    resource.record.profile_photo
  end
end
