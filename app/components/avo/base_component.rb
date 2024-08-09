# frozen_string_literal: true

class Avo::BaseComponent < ViewComponent::Base
  extend Literal::Properties
  include Turbo::FramesHelper

  def has_with_trial(ability)
    Avo.license.has_with_trial(ability)
  end

  private

  # Use the @parent_resource to fetch the field using the @reflection name.
  def field
    reflection_name = params[:related_name]&.to_sym || @reflection.name
    @parent_resource.get_field(reflection_name)
  rescue
    nil
  end

  # Fetch the resource and hydrate it with the record
  def association_resource
    resource = Avo.resource_manager.get_resource(params[:via_resource_class])

    model_class = if params[:via_relation_class].present?
      ::Avo::BaseResource.get_model_by_name params[:via_relation_class]
    else
      resource.model_class
    end

    resource = Avo.resource_manager.get_resource_by_model_class model_class if resource.blank?

    record = resource.find_record params[:via_record_id], query: model_class, params: params

    resource.new record: record
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_resource
    Avo.resource_manager.get_resource_by_model_class(@reflection.klass.to_s)
  rescue
    nil
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_parent_resource
    Avo.resource_manager.get_resource_by_model_class(@reflection.active_record.to_s)
  rescue
    nil
  end

  def parent_or_child_resource
    return @resource unless link_to_child_resource_is_enabled?
    return @resource if @resource.record.class.base_class == @resource.record.class

    Avo.resource_manager.get_resource_by_model_class(@resource.record.class) || @resource
  end

  def link_to_child_resource_is_enabled?
    enabled = field_linked_to_child_resource? if @parent_resource
    return enabled unless enabled.nil?

    @resource.link_to_child_resource
  end

  def field_linked_to_child_resource?
    resolved_field = @reflection ? @parent_resource.get_field(@reflection.name) : field
    resolved_field.link_to_child_resource if resolved_field.respond_to?(:link_to_child_resource)
  end
end
