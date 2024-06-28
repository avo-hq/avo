# frozen_string_literal: true

class Avo::Fields::FilesField::IndexComponent < Avo::Fields::IndexComponent
  def length
    @length ||= @field.value.attachments.length
  end
end
