# frozen_string_literal: true

class Avo::Fields::PasswordField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        autocomplete: @field.autocomplete
      }
    )
  end
end
