# frozen_string_literal: true

class Avo::Fields::ProgressBarField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: "w-full #{@field.get_html(:classes, view: view, element: :input)}",
        data: {
          action: "input->progress-bar-field#update",
          **@field.get_html(:data, view: view, element: :input)
        },
        max: @field.max,
        min: 0,
        step: @field.step
      }
    )
  end
end
