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

  # The Create button is dependent on the new? policy method.
  # The create? should be called only when the user clicks the Save button so the developers gets access to the params from the form.
  def can_see_the_create_button?
    @resource.authorization.authorize_action(:new, raise_exception: false) && simple_relation? && !has_reflection_and_is_read_only
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
    args = {}

    if @reflection.present?
      args = {
        via_relation_class: @parent_model.model_name,
        via_resource_id: @parent_model.id
      }

      if @reflection.inverse_of.present?
        args[:via_relation] = @reflection.inverse_of.name
      end
    end

    helpers.new_resource_path(model: @resource.model_class, resource: @resource, **args)
  end

  def attach_path
    "#{Avo::App.root_path}#{request.env["PATH_INFO"]}/new"
  end

  def singular_resource_name
    if @reflection.present?
      ::Avo::App.get_resource_by_model_name(@reflection.class_name).name
    else
      @resource.singular_name || @resource.model_class.model_name.name.downcase
    end
  end

  private

  def simple_relation?
    return @reflection.is_a? ::ActiveRecord::Reflection::HasManyReflection if @reflection.present?

    true
  end
end
