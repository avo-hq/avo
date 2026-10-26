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
    file.image?
  rescue
    false
  end

  def is_audio?
    file.audio?
  rescue
    false
  end

  def is_video?
    file.video?
  rescue
    false
  end

  def render?
    record_persisted? && blob_persisted?
  end

  # A blob is saved only when its record is. After a failed validation the
  # attachment lives in memory alone, and every URL built from it -- image src,
  # download link -- dies on `signed_id`. The file isn't attached, so skip it.
  def blob_persisted?
    file.nil? || file.blob&.persisted?
  end

  # If record is not persistent blob is automatically destroyed otherwise it can be "lost" on storage
  def record_persisted?
    return true if @resource.record.persisted?

    ActiveStorage::Blob.destroy(file.blob_id) if file.blob_id.present?
    false
  end

  # Only images open in the lightbox; audio, video and documents keep their players and links.
  def lightbox?
    @field.lightbox_for?(file)
  end

  # The trigger's accessible name. Without `display_filename` the filename shows
  # nowhere else, so it stays out of the label too.
  def preview_label
    @field.display_filename ? t("avo.preview_item", item: file.filename) : t("avo.image_preview")
  end

  def image_src
    @image_src ||= helpers.safe_image_url(file)
  end

  def download_url
    @download_url ||= helpers.main_app.url_for(file)
  end

  # One policy check per file: the document link and the lightbox both ask.
  def can_download_file?
    return @can_download_file if defined?(@can_download_file)

    @can_download_file = super
  end

  def image_arguments
    {
      class: "rounded-lg max-w-full h-auto self-start object-cover #{@extra_classes}",
      loading: :lazy,
      width: file.metadata["width"],
      height: file.metadata["height"]
    }
  end

  # Marks an element as one of the gallery's lightbox items and hands the
  # controller the image it opens. The caption follows `display_filename`, and
  # the original is linked only when the user may download the file, matching
  # the download control.
  def lightbox_item_data
    {
      image_lightbox_target: "item",
      action: "click->image-lightbox#open",
      image_lightbox_src_param: image_src,
      image_lightbox_title_param: (file.filename.to_s if @field.display_filename),
      image_lightbox_original_param: (download_url if can_download_file?)
    }.compact
  end

  def document_arguments
    args = {
      class: class_names(
        "relative flex flex-col justify-evenly items-center px-2 rounded-lg border bg-primary border-tertiary min-h-24",
        {
          "hover:bg-secondary transition": file.representable?
        }
      )
    }

    if file.representable? && can_download_file?
      args.merge!(
        {
          href: download_url,
          target: "_blank",
          rel: "noopener noreferrer"
        }
      )
    end

    args
  end
end
