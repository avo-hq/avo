# frozen_string_literal: true

class Avo::Fields::BelongsToField::ShowComponent < Avo::Fields::ShowComponent
  def resource_path
    return edit_path if Avo.configuration.skip_show_view

    helpers.resource_path(
      model: @field.value,
      resource: @field.target_resource,
      via_resource_class: @resource.model_class,
      via_resource_id: @resource.model.id
    )
  end

  def edit_path
    args = {
      via_resource_class: @resource.model_class,
      via_resource_id: @resource.model.id
    }

    helpers.edit_resource_path(model: @field.value, resource: @field.target_resource, **args)
  end
end
