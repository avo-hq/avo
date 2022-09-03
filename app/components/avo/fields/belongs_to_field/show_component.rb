# frozen_string_literal: true

class Avo::Fields::BelongsToField::ShowComponent < Avo::Fields::ShowComponent
  def resource_path
    if Avo.configuration.skip_show_view
      helpers.edit_resource_path(
        model: @field.value,
        resource: @field.target_resource,
        **{
          via_resource_class: @resource.model_class,
          via_resource_id: @resource.model.id
        }
      )
    else
      helpers.resource_path(
        model: @field.value,
        resource: @field.target_resource,
        via_resource_class: @resource.model_class,
        via_resource_id: @resource.model.id
      )
    end
  end
end
