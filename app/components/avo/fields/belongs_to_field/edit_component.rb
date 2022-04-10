# frozen_string_literal: true

class Avo::Fields::BelongsToField::EditComponent < Avo::Fields::EditComponent
  def initialize(field: nil, resource: nil, index: 0, form: nil, displayed_in_modal: false)
    super field: field, resource: resource, index: index, form: form, displayed_in_modal: displayed_in_modal

    @polymorphic_record = nil
  end

  def disabled
    return true if @field.readonly

    # When visiting the record through it's association we keep the field disabled by default
    # We make an exception when the user deliberately instructs Avo to allow detaching in this scenario
    return !@field.allow_via_detaching if @field.target_resource.present? && @field.target_resource.model_class.name == params[:via_resource_class]
    return !@field.allow_via_detaching if @field.id.to_s == params[:via_relation].to_s

    false
  end

  def is_polymorphic?
    @field.types.present?
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

  # Get the actual resource
  def polymorphic_record
    return unless has_polymorphic_association?

    return unless is_polymorphic?

    return @polymorphic_record if @polymorphic_record.present?

    @polymorphic_record = polymorphic_class.safe_constantize.find polymorphic_id

    @polymorphic_record
  end
end
