# frozen_string_literal: true

class Avo::Fields::Common::SingleFileViewerComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(file: nil, field:, resource:)
    @file = file
    @field = field
    @resource = resource
  end

  def destroy_path
    "#{@resource.record_path}/active_storage_attachments/#{id}/#{file.id}"
  end

  def id
    @field.id
  end

  def file
    @file || @field.value.attachment
  rescue
    nil
  end

  def is_image?
    file.image? || @field.is_image
  rescue
    false
  end

  def is_audio?
    file.audio? || @field.is_audio
  rescue
    false
  end

  def is_video?
    file.video? || @field.is_video
  rescue
    false
  end
end
