# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::GridItemComponent < Avo::BaseComponent
  include Avo::Fields::Concerns::FileAuthorization

  prop :field
  prop :resource
  prop :file
  prop :extra_classes

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

  def document_arguments
    args = {
      class: class_names(
        "relative flex flex-col justify-evenly items-center px-2 rounded-lg border bg-white border-gray-500 min-h-24",
        {
          "hover:bg-gray-100 transition": file.representable?
        }
      )
    }

    if file.representable? && can_download_file?
      args.merge!(
        {
          href: helpers.main_app.url_for(file),
          target: "_blank",
          rel: "noopener noreferrer"
        }
      )
    end

    args
  end
end
