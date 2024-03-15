# frozen_string_literal: true

class Avo::Fields::BooleanField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: "text-lg h-4 w-4 checked:bg-primary-400 focus:checked:!bg-primary-400 rounded #{@field.get_html(:classes, view: view, element: :input)}"
      }
    )
  end
end
