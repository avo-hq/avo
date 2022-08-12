# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  def initialize(**args)
    @resource_name = args[:resource_name]
    @resource_id = args[:resource_id]

    super(**args)
  end

  def resource_name
    @resource_name || @resource&.model_key
  end

  def resource_id
    @resource_id || @resource&.model&.id
  end

  def trix_id
    "trix_#{@resource_name}_#{@field.id}"
  end
end
