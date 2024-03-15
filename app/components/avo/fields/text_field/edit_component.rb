# frozen_string_literal: true

class Avo::Fields::TextField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        multiple: multiple,
        autocomplete: @field.autocomplete
      }
    )
  end
end
