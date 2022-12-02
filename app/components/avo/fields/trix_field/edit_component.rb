# frozen_string_literal: true

class Avo::Fields::TrixField::EditComponent < Avo::Fields::EditComponent
  attr_reader :resource

  def initialize(**args)
    @resource = args[:resource]
    @resource_id = args[:resource_id]
    @resource_name = args[:resource_name]

    super(**args)
  end

  def resource_name
    @resource_name || resource&.singular_route_key
  end

  def resource_id
    @resource_id || resource&.model&.id
  end

  def trix_id
    if resource_name.present?
      "trix_#{resource_name}_#{@field.id}"
    elsif form.present?
      "trix_#{form.index}_#{@field.id}"
    end
  end
end
