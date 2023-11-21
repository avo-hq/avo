# frozen_string_literal: true

class Avo::Views::ResourceEditComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  attr_reader :actions, :display_breadcrumbs

  def initialize(resource: nil, record: nil, actions: [], view: "edit", display_breadcrumbs: true)
    @resource = resource
    @record = record
    @actions = actions
    @view = Avo::ViewInquirer.new(view)
    @display_breadcrumbs = @reflection.blank? && display_breadcrumbs
  end

  def title
    @resource.default_panel_name
  end

  def back_path
    return if via_belongs_to?
    return resource_view_path if via_resource?
    return resources_path if via_index?

    if is_edit? && Avo.configuration.resource_default_view.show? # via resource show or edit page
      return helpers.resource_path(record: @resource.record, resource: @resource)
    end

    resources_path
  end

  def resources_path
    helpers.resources_path(resource: @resource)
  end

  def resource_view_path
    helpers.resource_view_path(record: association_resource.record, resource: association_resource)
  end

  def can_see_the_destroy_button?
    return super if is_edit? && Avo.configuration.resource_default_view.edit?

    false
  end

  # The save button is dependent on the edit? policy method.
  # The update? method should be called only when the user clicks the Save button so the developer gets access to the params from the form.
  def can_see_the_save_button?
    @resource.authorization.authorize_action @view, raise_exception: false
  end

  def controls
    @resource.render_edit_controls
  end

  # Render :show view for read only trix fields
  def view_for(field)
    field.is_a?(Avo::Fields::TrixField) && field.is_disabled? ? :show : view
  end

  private

  def via_index?
    params[:via_view] == "index"
  end

  def via_belongs_to?
    params[:via_belongs_to_resource_class].present?
  end

  def is_edit?
    view.in?(%w[edit update])
  end

  def form_method
    return :put if is_edit?

    :post
  end

  def form_url
    if is_edit?
      helpers.resource_path(
        record: @resource.record,
        resource: @resource
      )
    else
      helpers.resources_path(
        resource: @resource,
        via_relation_class: params[:via_relation_class],
        via_relation: params[:via_relation],
        via_record_id: params[:via_record_id]
      )
    end
  end
end
