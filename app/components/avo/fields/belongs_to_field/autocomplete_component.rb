# frozen_string_literal: true

class Avo::Fields::BelongsToField::AutocompleteComponent < ViewComponent::Base
  def initialize(form:, field:, model_key:, foreign_key:, disabled:, type: nil, resource: nil, polymorphic_record: nil)
    @form = form
    @field = field
    @type = type
    @model_key = model_key
    @foreign_key = foreign_key
    @resource = resource
    @disabled = disabled
    @polymorphic_record = polymorphic_record
  end

  def field_label
    if searchable?
      # New records won't have the value (instantiated model) present but the polymorphic_type and polymorphic_id prefilled
      if new_record? && has_polymorphic_association?
        @polymorphic_record.send(polymorphic_fields[:label])
      else
        @field.value&.class == @type ? @field.field_label : nil
      end
    else
      @field.field_label
    end
  end

  def field_value
    if searchable?
      # New records won't have the value (instantiated model) present but the polymorphic_type and polymorphic_id prefilled
      if new_record? && has_polymorphic_association?
        @polymorphic_record.send(polymorphic_fields[:id])
      else
        @field.value&.class == @type ? @field.field_value : nil
      end
    else
      @field.field_value
    end
  end

  private

  def searchable?
    @type.present?
  end

  def new_record?
    @resource.model.new_record?
  end

  def has_polymorphic_association?
    polymorphic_class.present? && polymorphic_id.present?
  end

  # Get the polymorphic class
  def polymorphic_class
    @resource.model["#{@field.foreign_key}_type"]
  end

  # Get the polymorphic id
  def polymorphic_id
    @resource.model["#{@field.foreign_key}_id"]
  end

  # Get the resource for that polymorphic class
  def polymorphic_resource
    ::Avo::App.get_resource_by_model_name polymorphic_class
  end

  # Extract the needed fields to identify the record for polymorphic associations
  def polymorphic_fields
    {
      id: polymorphic_resource.id,
      label: polymorphic_resource.title
    }
  end
end
