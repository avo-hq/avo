# frozen_string_literal: true

class Avo::Fields::NumberField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        max: @field.max,
        min: @field.min,
        step: @field.step,
        autocomplete: @field.autocomplete
      }
    )
  end
end
