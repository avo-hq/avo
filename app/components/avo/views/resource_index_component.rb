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
    parent_model: nil,
    parent_resource: nil,
    applied_filters: [],
    query: nil
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
    @parent_resource = parent_resource
    @applied_filters = applied_filters
    @view = :index
    @query = query
  end

  def title
    if @reflection.present?
      return name if field.present?

      reflection_resource.plural_name
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
    return authorize_association_for(:create) if @reflection.present?

    @resource.authorization.authorize_action(:new, raise_exception: false) && !has_reflection_and_is_read_only
  end

  def can_attach?
    klass = @reflection
    klass = @reflection.through_reflection if klass.is_a? ::ActiveRecord::Reflection::ThroughReflection

    @reflection.present? && klass.is_a?(::ActiveRecord::Reflection::HasManyReflection) && !has_reflection_and_is_read_only && authorize_association_for(:attach)
  end

  def create_path
    args = {}

    if @reflection.present?
      args = {
        via_relation_class: reflection_model_class,
        via_resource_id: @parent_model.to_param
      }

      if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
        args[:via_relation] = params[:resource_name]
      end

      if @reflection.is_a? ActiveRecord::Reflection::HasManyReflection
        args[:via_relation] = @reflection.name
      end

      if @reflection.parent_reflection.present? && @reflection.parent_reflection.inverse_of.present?
        args[:via_relation] = @reflection.parent_reflection.inverse_of.name
      end

      if @reflection.inverse_of.present?
        args[:via_relation] = @reflection.inverse_of.name
      end
    end

    helpers.new_resource_path(resource: @resource, **args)
  end

  def attach_path
    current_path = CGI.unescape(request.env["PATH_INFO"]).split("/").select(&:present?)

    Avo::App.root_path(paths: [*current_path, "new"])
  end

  def singular_resource_name
    if @reflection.present?
      return name.singularize if field.present?

      reflection_resource.name
    else
      @resource.singular_name || @resource.model_class.model_name.name.downcase
    end
  end

  def description
    # If this is a has many association, the user can pass a description to be shown just for this association.
    if @reflection.present?
      return field.description if field.present? && field.description

      return
    end

    @resource.resource_description
  end

  def hide_search_input
    return true unless @resource.search_query.present?

    field&.hide_search_input || false
  end

  private

  def reflection_model_class
    @reflection.active_record.to_s
  end

  def name
    field.custom_name? ? field.name : field.plural_name
  end

  def via_reflection
    return unless @reflection.present?

    {
      association: "has_many",
      association_id: @reflection.name,
      class: reflection_model_class,
      id: @parent_model.to_param
    }
  end
end
