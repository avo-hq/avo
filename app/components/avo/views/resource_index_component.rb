# frozen_string_literal: true

class Avo::Views::ResourceIndexComponent < Avo::ResourceComponent
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
    turbo_frame: "",
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
    @turbo_frame = turbo_frame
    @parent_model = parent_model
  end

  def title
    if @reflection.present?
      ::Avo::App.get_resource_by_model_name(@reflection.class_name).plural_name
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
    @resource.authorization.authorize_action(:create, raise_exception: false) && simple_relation? && !has_reflection_and_is_read_only
  end

  def can_attach?
    klass = @reflection
    klass = @reflection.through_reflection if klass.is_a? ::ActiveRecord::Reflection::ThroughReflection

    @reflection.present? && klass.is_a?(::ActiveRecord::Reflection::HasManyReflection) && !has_reflection_and_is_read_only && authorize_association_for("attach")
  end

  def has_reflection_and_is_read_only
    if @reflection.present? && @reflection.active_record.name && @reflection.name
      fields = ::Avo::App.get_resource_by_model_name(@reflection.active_record.name).get_field_definitions
      filtered_fields = fields.filter{ |f| f.id == @reflection.name}
    else
      return false
    end

    if filtered_fields.present?
      filtered_fields.find { |f| f.id == @reflection.name }.readonly
    else
      false
    end
  end

  def create_path
    if @reflection.present?
      path_args = {
        via_relation_class: @parent_model.model_name,
        via_resource_id: @parent_model.id
      }

      if @reflection.inverse_of.present?
        path_args[:via_relation] = @reflection.inverse_of.name
      end

      helpers.new_resource_path(@resource.model_class, for_resource: @resource, **path_args)
    else
      helpers.new_resource_path(@resource.model_class, for_resource: @resource)
    end
  end

  def attach_path
    "#{Avo::App.root_path}#{request.env["PATH_INFO"]}/new"
  end

  def singular_resource_name
    if @reflection.present?
      ::Avo::App.get_resource_by_model_name(@reflection.class_name).name
    else
      @resource.singular_name.present? ? @resource.singular_name : @resource.model_class.model_name.name.downcase
    end
  end

  private

  def simple_relation?
    return @reflection.is_a? ::ActiveRecord::Reflection::HasManyReflection if @reflection.present?

    true
  end
end
