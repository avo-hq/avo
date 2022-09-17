# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  def trix_id
    "trix_#{@resource.class_name_without_resource.underscore}_#{@field.id}"
  end
end
