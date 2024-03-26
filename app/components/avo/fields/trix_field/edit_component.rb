# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  attr_reader :resource

  def initialize(**args)
    @resource = args[:resource]
    @resource_id = args[:resource_id] || @resource&.record&.id
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
      attachments_disabled: @field.attachments_disabled,
      attachment_key: @field.attachment_key,
      hide_attachment_filename: @field.hide_attachment_filename,
      hide_attachment_filesize: @field.hide_attachment_filesize,
      hide_attachment_url: @field.hide_attachment_url,
      is_active_text: @field.is_active_text?,
    }.transform_keys { |key| "trix_field_#{key}_value" }
  end
end
