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
      if @field.is_polymorphic?
        if new_record? && has_polymorphic_association?
          # @polymorphic_record.send(polymorphic_fields[:label])
          @field.field_label
        else
          @field.value&.class == @type ? @field.field_label : nil
        end
      else
        @field.field_label
      end
    else
      @field.field_label
    end
  end

  def field_value
    result = @field.field_value
    # abort searchable?.inspect
    if searchable?
      # abort [new_record?].inspect
      # New records won't have the value (instantiated model) present but the polymorphic_type and polymorphic_id prefilled
      if @field.is_polymorphic?
        if new_record? && has_polymorphic_association?
          # abort polymorphic_fields[:id].inspect
          # @polymorphic_record.send(polymorphic_fields[:id])
          result = @field.field_value
        else
          # abort @field.field_value.inspect
          result = @field.value&.class == @type ? @field.field_value : nil
        end
      end
    else
      # abort @field.field_value.inspect
      result = @field.field_value
    end

    result
  end

  private

  def searchable?
    @field.searchable
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
