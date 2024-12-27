# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  attr_reader :resource

  def initialize(**args)
    @resource = args[:resource]
    @resource_id = args[:resource_id] || @resource&.record&.to_param
    @resource_name = args[:resource_name] || @resource&.singular_route_key

    super(**args)

    @unique_random_id = SecureRandom.hex(4)
  end

  def unique_id
    if @resource_name.present?
      "trix_#{@resource_name}_#{@field.id}_#{@unique_random_id}"
    elsif form.present?
      "trix_#{form.index}_#{@field.id}_#{@unique_random_id}"
    end
  end

  def unique_selector = ".#{unique_id}"

  # The controller element should have a unique_selector attribute.
  # It's used to identify the specific editor for the media library to delegate the attach event to.
  def data
    values = {
      resource_name: @resource_name,
      resource_id: @resource_id,
      unique_selector:, # mandatory
      attachments_disabled: @field.attachments_disabled,
      attachment_key: @field.attachment_key,
      hide_attachment_filename: @field.hide_attachment_filename,
      hide_attachment_filesize: @field.hide_attachment_filesize,
      hide_attachment_url: @field.hide_attachment_url,
      is_action_text: @field.is_action_text?,
      upload_warning: t("avo.you_cant_upload_new_resource"),
      attachment_disable_warning: t("avo.this_field_has_attachments_disabled"),
      attachment_key_warning: t("avo.you_havent_set_attachment_key")
    }.transform_keys { |key| "trix_field_#{key}_value" }

    {
      controller: "trix-field",
      trix_field_target: "controller",
      action: "insert-attachment->trix-field#insertAttachment",
      **values,
    }
  end
end
