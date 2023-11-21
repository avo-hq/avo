# frozen_string_literal: true

class Avo::Fields::BelongsToField::ShowComponent < Avo::Fields::ShowComponent
  def resource_view_path
    helpers.resource_view_path(
      record: @field.value,
      resource: @field.target_resource,
      via_resource_class: @resource.class.to_s,
      via_record_id: @resource.record.to_param
    )
  end
end
