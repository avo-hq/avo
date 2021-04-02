# frozen_string_literal: true

class Avo::Edit::Fields::BelongsToFieldComponent < Avo::Edit::Fields::FieldComponent
  def disabled
    return true if @field.readonly
    return true if @field.target_resource.model_class.name == params[:via_resource_class]

    false
  end
end
