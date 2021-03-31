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
      (@reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) || @reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection))
  end

  def can_edit?
    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_view?
    @resource.authorization.authorize_action(:show, raise_exception: false)
  end

  def show_path
    if @parent_model.present?
      helpers.resource_path(@resource.model, via_resource_class: @parent_model.class, via_resource_id: @parent_model.id)
    else
      helpers.resource_path(@resource.model)
    end
  end

  def edit_path
    if @parent_model.present?
      helpers.edit_resource_path(@resource.model, via_resource_class: @parent_model.class, via_resource_id: @parent_model.id)
    else
      helpers.edit_resource_path(@resource.model)
    end
  end
end
