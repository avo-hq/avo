# frozen_string_literal: true

class Avo::Fields::BelongsToField::ShowComponent < Avo::Fields::ShowComponent
  # TODO: after some refactor this should be calld by one single line: helpers.resource_default_view_path
  def resource_default_view_path
    Avo.configuration.skip_show_view ? edit_path : resource_path
  end

  def resource_path
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
