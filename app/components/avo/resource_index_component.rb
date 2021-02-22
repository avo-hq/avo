# frozen_string_literal: true

class Avo::ResourceIndexComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(
    resource: nil,
    resources: nil,
    models: [],
    pagy: nil,
    index_params: {},
    filters: [],
    actions: [],
    reflection: nil,
    frame_name: '',
    parent_model: nil
  )
    @resource = resource
    @resources = resources
    @models = models
    @pagy = pagy
    @index_params = index_params
    @filters = filters
    @actions = actions
    @reflection = reflection
    @frame_name = frame_name
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

  def can_attach?
    klass = @reflection
    klass = @reflection.through_reflection if klass.is_a? ::ActiveRecord::Reflection::ThroughReflection

    @reflection.present? && klass.is_a?(::ActiveRecord::Reflection::HasManyReflection)
  end

  def can_detach?
    @reflection.present? && @reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection) && @models.present?
  end

  def create_path
    if @reflection.present?
      path_args = {
        via_relation_class: @parent_model.model_name,
        via_resource_id: @parent_model.id,
      }

      if @reflection.inverse_of.present?
        path_args[:via_relation] = @reflection.inverse_of.name
      end

      helpers.new_resource_path(@resource.model_class, **path_args)
    else
      helpers.new_resource_path(@resource.model_class)
    end
  end

  def attach_path
    "#{Avo.configuration.root_path}#{request.env['PATH_INFO']}/new"
  end

  def detach_path
    helpers.resource_detach_path(via_resource_name, via_resource_id, via_relation_param, @models.first.id)
  end

  private
    def simple_relation?
      @reflection.is_a? ::ActiveRecord::Reflection::HasManyReflection
    end
end
