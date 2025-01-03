# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  attr_reader :resource

  def initialize(**args)
    @resource = args[:resource]
    @resource_id = args[:resource_id] || @resource&.record&.to_param
    @resource_name = args[:resource_name] || @resource&.singular_route_key

    super(**args)
  end

  def trix_id
    if @resource_name.present?
      "trix_#{@resource_name}_#{@field.id}"
    elsif form.present?
      "trix_#{form.index}_#{@field.id}"
    end
  end

  def data_values
    {
      resource_name: @resource_name,
      resource_id: @resource_id,
      attachment_upload_url: build_attachment_path,
      # enabled if its an action_text and not explicitely disabled
      attachments_disabled: ( @field.attachments_disabled and not @field.is_action_text?),
      attachment_key: @field.attachment_key,
      hide_attachment_filename: @field.hide_attachment_filename,
      hide_attachment_filesize: @field.hide_attachment_filesize,
      hide_attachment_url: @field.hide_attachment_url,
      is_action_text: @field.is_action_text?,
      upload_warning: t("avo.you_cant_upload_new_resource"),
      attachment_disable_warning: t("avo.this_field_has_attachments_disabled"),
      attachment_key_warning: t("avo.you_havent_set_attachment_key")
    }.transform_keys { |key| "trix_field_#{key}_value" }
  end

  def build_attachment_path
    if @field.is_action_text?
      rails_direct_uploads_url
    else
      "#{Avo.configuration.root_path}/avo_api/resources/#{@resource_name}/#{@resource_id}/attachments"
    end
  end

end
