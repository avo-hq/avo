# frozen_string_literal: true

class Avo::Fields::BooleanGroupField::EditComponent < Avo::Fields::EditComponent
  def initialize(...)
    super(...)

    # Initilize here to avoid multiple calls to @field.get_html for each option.
    @classes = "w-4 h-4 rounded checked:bg-primary-400 focus:checked:!bg-primary-400" \
      "#{@field.get_html(:classes, view: view, element: :input)}"
    @data = @field.get_html(:data, view: view, element: :input)
    @style = @field.get_html(:style, view: view, element: :input)
    @form_scope = @form.object_name
  end

  # Get the state of each checkboxe from either the form that returns a validation error or from the model itself.
  def checked?(id)
    if params[@form_scope].present? && params[@form_scope][@field.id.to_s].present?
      params[@form_scope][@field.id.to_s].include?(id.to_s)
    elsif @field.value.present?
      @field.value.with_indifferent_access[id]
    end
  end
end
