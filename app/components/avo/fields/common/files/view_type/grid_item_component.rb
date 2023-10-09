# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::GridItemComponent < ViewComponent::Base
  attr_reader :field, :resource

  def initialize(field:, resource:, file: nil, extra_classes: nil)
    @file = file
    @field = field
    @resource = resource
    @extra_classes = extra_classes
  end

  def id
    field.id
  end

  def file
    @file || field.value.attachment
  rescue
    nil
  end

  def is_image?
    file.image? || field.is_image
  rescue
    false
  end

  def is_audio?
    file.audio? || field.is_audio
  rescue
    false
  end

  def is_video?
    file.video? || field.is_video
  rescue
    false
  end

  def render?
    record_persisted?
  end

  # If model is not persistent blob is automatically destroyed otherwise it can be "lost" on storage
  def record_persisted?
    return true if @resource.model.persisted?

    ActiveStorage::Blob.destroy(file.blob_id) if file.blob_id.present?
    false
  end
end
