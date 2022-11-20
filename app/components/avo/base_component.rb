# frozen_string_literal: true

class Avo::BaseComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def has_with_trial(ability)
    ::Avo::App.license.has_with_trial(ability)
  end

  private

  # Use the @parent_resource to fetch the field using the @reflection name.
  def field
    @parent_resource.get_field_definitions.find { |f| f.id == @reflection.name }
  rescue
    nil
  end

  # Fetch the resource and hydrate it with the model
  def association_resource
    resource = ::Avo::App.get_resource(params[:via_resource_class])
    model_class_name = params[:via_relation_class] || resource.model_class

    model_klass = ::Avo::BaseResource.valid_model_class model_class_name

    model = model_klass.find params[:via_resource_id]

    resource = ::Avo::App.get_resource_by_model_name model_klass if resource.blank?

    resource.dup.hydrate model: model
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_resource
    ::Avo::App.get_resource_by_model_name(@reflection.klass.to_s)
  rescue
    nil
  end

  # Get the resource for the resource using the klass attribute so we get the namespace too
  def reflection_parent_resource
    ::Avo::App.get_resource_by_model_name(@reflection.active_record.to_s)
  rescue
    nil
  end

  def parent_or_child_resource
    return @resource unless link_to_child_resource_is_enabled?
    return @resource if @resource.model.class.base_class == @resource.model.class

    ::Avo::App.get_resource_by_model_name(@resource.model.class).dup || @resource
  end

  def link_to_child_resource_is_enabled?
    return field_linked_to_child_resource? if @parent_resource

    @resource.link_to_child_resource
  end

  def field_linked_to_child_resource?
    field.present? && field.respond_to?(:link_to_child_resource) && field.link_to_child_resource
  end
end
