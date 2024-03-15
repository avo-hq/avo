# frozen_string_literal: true

class Avo::Fields::FileField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
  def field_input_args
    super.merge(
      {
        accept: @field.accept,
        direct_upload: @field.direct_upload,
        disabled: disabled?,
        class: "w-full"
      }
    )
  end
end
