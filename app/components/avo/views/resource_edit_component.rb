# frozen_string_literal: true

class Avo::Views::ResourceEditComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  prop :resource
  prop :record
  prop :actions, default: [].freeze
  prop :view, default: Avo::ViewInquirer.new(:edit).freeze
  prop :display_breadcrumbs, default: true, reader: :public

  attr_reader :query

  def initialize(resource:, query: nil, prefilled_fields: nil, **args)
    @query = query
    @prefilled_fields = prefilled_fields
    super(resource: resource, **args)
  end

  def after_initialize
    @display_breadcrumbs = @reflection.blank? && display_breadcrumbs
  end

  def title
    @resource.default_panel_name
  end

  def back_path
    if from_bulk_update?
      helpers.resources_path(resource: @resource)
    elsif returning_to_explicit_path?
      params[:return_to]
    elsif via_belongs_to?
      nil
    elsif via_resource?
      resource_view_path
    elsif via_index?
      resources_path
    elsif returning_to_editable_show?
      helpers.resource_path(record: @resource.record, resource: @resource, **keep_referrer_params)
    else
      resources_path
    end
  end

  def resources_path
    helpers.resources_path(resource: @resource, **keep_referrer_params)
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
    (field.is_a?(Avo::Fields::TrixField) && field.is_disabled?) ? :show : @view
  end

  private

  def from_bulk_update?
    params[:controller] == "avo/bulk_update"
  end

  def returning_to_explicit_path?
    params[:return_to].present?
  end

  def resource_show_path
    helpers.resource_path(record: @resource.record, resource: @resource, **keep_referrer_params)
  end

  def returning_to_editable_show?
    is_edit? && Avo.configuration.resource_default_view.show?
  end

  def via_index?
    params[:via_view] == "index"
  end

  def is_edit?
    @view.in?(%w[edit update])
  end

  def form_method
    return :put if is_edit? && params[:controller] != "avo/bulk_update"

    :post
  end

  def model
    @resource.record
  end

  def form_url
    if params[:controller] == "avo/bulk_update"
      helpers.handle_bulk_update_path(resource_name: @resource.name, query: @query)
    elsif is_edit?
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
