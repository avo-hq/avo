# frozen_string_literal: true

class Avo::Views::ResourceIndexComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  attr_reader :scopes, :query, :turbo_frame, :parent_record, :parent_resource, :resource, :actions

  def initialize(
    resource: nil,
    resources: nil,
    records: [],
    pagy: nil,
    index_params: {},
    filters: [],
    actions: [],
    reflection: nil,
    turbo_frame: "",
    parent_record: nil,
    parent_resource: nil,
    applied_filters: [],
    query: nil,
    scopes: nil
  )
    @resource = resource
    @resources = resources
    @records = records
    @pagy = pagy
    @index_params = index_params
    @filters = filters
    @actions = actions
    @reflection = reflection
    @turbo_frame = turbo_frame
    @parent_record = parent_record
    @parent_resource = parent_resource
    @applied_filters = applied_filters
    @view = Avo::ViewInquirer.new("index")
    @query = query
    @scopes = scopes
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
        via_resource_class: @parent_resource.class,
        via_relation_class: reflection_model_class,
        via_record_id: @parent_record.to_param
      }

      if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
        args[:via_relation] = params[:resource_name]
      end

      if @reflection.is_a? ActiveRecord::Reflection::HasManyReflection
        args[:via_relation] = @reflection.name
      end

      if @reflection.inverse_of.present?
        args[:via_relation] = @reflection.inverse_of.name
      end
    end

    helpers.new_resource_path(resource: @resource, **args)
  end

  def attach_path
    current_path = CGI.unescape(request.env["PATH_INFO"]).split("/").select(&:present?)

    Avo.root_path(paths: [*current_path, "new"])
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

    @resource.description
  end

  def show_search_input
    return false unless authorized_to_search?
    return false unless resource.class.search_query.present?
    return false if field&.hide_search_input

    true
  end

  def authorized_to_search?
    # Hide the search if the authorization prevents it
    return true unless resource.authorization.respond_to?(:has_action_method?)
    return true unless resource.authorization.has_action_method?("search")

    resource.authorization.authorize_action("search", raise_exception: false)
  end

  def render_dynamic_filters_button
    return unless Avo.avo_dynamic_filters_installed?
    return unless resource.has_filters?
    return if Avo::DynamicFilters.configuration.always_expanded

    a_button size: :sm,
      color: :primary,
      icon: "filter",
      data: {
        controller: "avo-filters",
        action: "click->avo-filters#toggleFiltersArea",
        avo_filters_dynamic_filters_component_id_value: dynamic_filters_component_id
      } do
      Avo::DynamicFilters.configuration.button_label
    end
  end

  def scopes_list
    Avo::Pro::Scopes::ListComponent.new(
      scopes: scopes,
      resource: resource,
      turbo_frame: turbo_frame,
      parent_record: parent_record
    )
  end

  def can_render_scopes?
    defined?(Avo::Pro)
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
      id: @parent_record.to_param,
      view: @parent_resource.view
    }
  end

  def header_visible?
    search_query_present? || filters_present? || has_many_view_types? || has_dynamic_filters?
  end

  def has_dynamic_filters?
    Avo.avo_dynamic_filters_installed? && resource.has_filters?
  end

  def search_query_present?
    @resource.class.search_query.present?
  end

  def filters_present?
    @filters.present?
  end

  def has_many_view_types?
    available_view_types.count > 1
  end

  # Generate a unique component id for the current component.
  # This is used to identify the component in the DOM.
  def dynamic_filters_component_id
    @dynamic_filters_component_id ||= "dynamic_filters_component_id_#{SecureRandom.hex(3)}"
  end
end
