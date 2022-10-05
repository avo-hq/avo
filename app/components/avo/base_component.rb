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
  def relation_resource
    model_class_name = params[:via_resource_class] || params[:via_relation_class]
    model_klass = ::Avo::BaseResource.valid_model_class model_class_name

    resource = ::Avo::App.get_resource_by_model_name model_klass
    model = model_klass.find params[:via_resource_id]

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
end
