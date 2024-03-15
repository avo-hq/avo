# frozen_string_literal: true

class Avo::Fields::FilesField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
  def field_input_args
    super.merge(
      {
        accept: @field.accept,
        direct_upload: @field.direct_upload,
        disabled: disabled?,
        multiple: true,
        class: "w-full"
      }
    )
  end
end
