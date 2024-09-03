# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::GridItemComponent < Avo::BaseComponent
  prop :field, Avo::Fields::BaseField
  prop :resource, Avo::BaseResource
  prop :file, _Nilable(ActiveStorage::Attachment) if defined?(ActiveStorage::Attachment)
  prop :extra_classes, _Nilable(String)

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

  def render?
    record_persisted?
  end

  # If record is not persistent blob is automatically destroyed otherwise it can be "lost" on storage
  def record_persisted?
    return true if @resource.record.persisted?

    ActiveStorage::Blob.destroy(file.blob_id) if file.blob_id.present?
    false
  end
end
