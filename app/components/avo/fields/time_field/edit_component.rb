# frozen_string_literal: true

class Avo::Fields::TimeField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        value: @field.edit_formatted_value,
        class: classes("w-full #{"hidden" unless params[:avo_show_hidden_inputs]}"),
        data: {
          "date-field-target": "input",
          placeholder: @field.placeholder,
          **@field.get_html(:data, view: view, element: :input)
        }
      }
    )
  end
end
