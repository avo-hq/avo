# frozen_string_literal: true

class Avo::Fields::BelongsToField::EditComponent < Avo::Fields::EditComponent
  def initialize(field: nil, resource: nil, index: 0, form: nil, compact: false)
    super field: field, resource: resource, index: index, form: form, compact: compact

    @polymorphic_record = nil
  end

  def disabled
    return true if @field.is_readonly? || @field.is_disabled?

    # When visiting the record through it's association we keep the field disabled by default
    # We make an exception when the user deliberately instructs Avo to allow detaching in this scenario
    return !@field.allow_via_detaching if @field.target_resource.present? && visit_through_association?
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

  def field_html_action
    @field.get_html(:data, view: @resource.view, element: :input).fetch(:action, nil)
  end

  private

  def visit_through_association?
    @field.target_resource.class.to_s == params[:via_resource_class].to_s
  end
end
