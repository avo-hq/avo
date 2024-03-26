# frozen_string_literal: true

class Avo::Fields::StatusField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        placeholder: @field.placeholder
      }
    )
  end
end
