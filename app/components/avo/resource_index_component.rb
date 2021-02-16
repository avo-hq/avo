# frozen_string_literal: true

class Avo::ResourceIndexComponent < ViewComponent::Base
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(
    resource: nil,
    resources: nil,
    models: [],
    pagy: nil,
    index_params: {},
    reflection: nil,
    frame_name: '',
    parent_resource: nil,
    parent_model: nil
  )
    @resource = resource
    @resources = resources
    @models = models
    @pagy = pagy
    @index_params = index_params
    @reflection = reflection
    @frame_name = frame_name
    @parent_resource = parent_resource
    @parent_model = parent_model
  end

  def title
    if @reflection.present?
      @reflection.plural_name.capitalize
    else
      @resource.plural_name
    end
  end

  def view_type
    @index_params[:view_type]
  end

  def available_view_types
    @index_params[:available_view_types]
  end

  def can_create?
    @resource.authorization.authorize_action(:create, raise_exception: false)
  end

  def can_attach?
    @reflection.present? && @reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) && @models.present?
  end

  def can_detach?
    @reflection.present? && @reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection) && @models.present?
  end

  def create_path
    if @reflection.present?
      helpers.new_resource_path(@resource.model_class, via_resource_name: @parent_resource.model_class, via_resource_id: @parent_model.id)
    else
      helpers.new_resource_path(@resource.model_class)
    end
  end

  def attach_path
    "#{Avo.configuration.root_path}/#{request.env['PATH_INFO']}/new"
  end

  def detach_path
    helpers.resource_detach_path(via_resource_name, via_resource_id, via_relation_param, @models.first.id)
  end
end
