# frozen_string_literal: true

class Avo::Fields::LocationField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full")
      }
    )
  end
end
