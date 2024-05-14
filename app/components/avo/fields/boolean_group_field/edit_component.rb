# frozen_string_literal: true

class Avo::Fields::BooleanGroupField::EditComponent < Avo::Fields::EditComponent
  def initialize(...)
    super(...)

    # Initilize here to avoid multiple calls to @field.get_html for each option.
    @classes = "w-4 h-4 rounded checked:bg-primary-400 focus:checked:!bg-primary-400" \
      "#{@field.get_html(:classes, view: view, element: :input)}"
    @data = @field.get_html(:data, view: view, element: :input)
    @style = @field.get_html(:style, view: view, element: :input)
    @model_param_key = model_name_from_record_or_class(@resource.record).param_key
  end

  # Get the state of each checkboxe from either the form that returns a validation error or from the model itself.
  def checked?(id)
    if params[@model_param_key].present? && params[@model_param_key][@field.id.to_s].present?
      return params[@model_param_key][@field.id.to_s].include?(id.to_s)
    else
      if @field.value.present?
        return @field.value[id.to_s]
      end
    end
  end
end
