# frozen_string_literal: true

class Avo::Index::ResourceControlsComponent < Avo::ResourceComponent
  def initialize(resource: nil, reflection: nil, parent_model: nil)
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
  end

  def can_detach?
    @reflection.present? &&
      @resource.model.present? &&
      (@reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) || @reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)) &&
      authorize_association_for("detach")
  end

  def can_edit?
    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_view?
    @resource.authorization.authorize_action(:show, raise_exception: false)
  end

  def show_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.model_class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.resource_path(model: @resource.model, resource: @resource, **args)
  end

  def edit_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.model_class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.edit_resource_path(model: @resource.model, resource: @resource, **args)
  end

  def singular_resource_name
    if @reflection.present?
      reflection_resource.name
    else
      @resource.singular_name.present? ? @resource.singular_name : @resource.model_class.model_name.name.downcase
    end
  end

  def parent_resource
    return nil if @parent_model.blank?

    ::Avo::App.get_resource_by_model_name @parent_model.class
  end
end
