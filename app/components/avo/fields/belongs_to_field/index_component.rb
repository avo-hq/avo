# frozen_string_literal: true

class Avo::Fields::BelongsToField::IndexComponent < Avo::Fields::IndexComponent
  def resource_path
    if Avo.configuration.skip_show_view
      helpers.edit_resource_path(model: @field.value, resource: @field.target_resource)
    else
      helpers.resource_path(model: @field.value, resource: @field.target_resource)
    end
  end
end
