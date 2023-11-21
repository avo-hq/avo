# frozen_string_literal: true

class Avo::Views::ResourceShowComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  attr_reader :actions, :display_breadcrumbs

  def initialize(resource: nil, reflection: nil, parent_resource: nil, parent_record: nil, resource_panel: nil, actions: [])
    @resource = resource
    @reflection = reflection
    @resource_panel = resource_panel
    @actions = actions
    @parent_record = parent_record
    @parent_resource = parent_resource
    @view = Avo::ViewInquirer.new("show")
    @display_breadcrumbs = reflection.blank?
  end

  def title
    if @reflection.present?
      return field.name if has_one_field?

      reflection_resource.name
    else
      @resource.default_panel_name
    end
  end

  def back_path
    if via_resource?
      helpers.resource_path(record: association_resource.model_class, resource: association_resource, resource_id: params[:via_record_id])
    else
      helpers.resources_path(resource: @resource)
    end
  end

  def edit_path
    args = {}

    if via_resource?
      args = {
        via_resource_class: params[:via_resource_class],
        via_record_id: params[:via_record_id]
      }
    end

    helpers.edit_resource_path(record: @resource.record, resource: @resource, **args)
  end

  def controls
    @resource.render_show_controls
  end

  def view_for(field)
    @view
  end

  private

  # In development and test environments we should show the invalid field errors
  def should_display_invalid_fields_errors?
    (Rails.env.development? || Rails.env.test?) && @resource.invalid_fields.present?
  end

  def has_one_field?
    field.present? and field.instance_of? Avo::Fields::HasOneField
  end
end
