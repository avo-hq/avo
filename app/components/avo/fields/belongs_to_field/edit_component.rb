# frozen_string_literal: true

class Avo::Fields::BelongsToField::EditComponent < Avo::Fields::EditComponent
  def disabled
    return true if @field.readonly
    return true if @field.target_resource.model_class.name == params[:via_resource_class]
    return true if @field.id.to_s == params[:via_relation].to_s

    false
  end
end
