# frozen_string_literal: true

class Avo::Fields::TextareaField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        rows: @field.rows
      }
    )
  end
end
