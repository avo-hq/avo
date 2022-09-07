# frozen_string_literal: true

class Avo::Fields::BelongsToField::IndexComponent < Avo::Fields::IndexComponent
  def resource_path
    return edit_path if Avo.configuration.skip_show_view

    helpers.resource_path(model: @field.value, resource: @field.target_resource)
  end

  def edit_path
    helpers.edit_resource_path(model: @field.value, resource: @field.target_resource)
  end
end
