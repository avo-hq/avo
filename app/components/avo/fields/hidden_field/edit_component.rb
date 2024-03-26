# frozen_string_literal: true

class Avo::Fields::HiddenField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: @field.get_html(:classes, view: view, element: :input)

      }
    )
  end
end
