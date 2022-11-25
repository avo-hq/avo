# frozen_string_literal: true

class Avo::Views::ResourceShowComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  attr_reader :resource

  def initialize(resource: nil, reflection: nil, parent_resource: nil, parent_model: nil, resource_panel: nil, actions: [])
    @resource = resource
    @reflection = reflection
    @resource_panel = resource_panel
    @actions = actions
    @parent_model = parent_model
    @parent_resource = parent_resource
    @view = :show
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
      helpers.resource_path(model: association_resource.model_class, resource: association_resource, resource_id: params[:via_resource_id])
    else
      helpers.resources_path(resource: @resource)
    end
  end

  def edit_path
    args = {}

    if via_resource?
      args = {
        via_resource_class: params[:via_resource_class],
        via_resource_id: params[:via_resource_id]
      }
    end

    helpers.edit_resource_path(model: @resource.model, resource: @resource, **args)
  end

  def back_buttons
    show_controlls.select { |control| control.back_button? }
  end

  def delete_buttons
    show_controlls.select { |control| control.delete_button? }
  end

  def edit_buttons
    show_controlls.select { |control| control.edit_button? }
  end

  def actions_lists
    show_controlls.select { |control| control.actions_list? }
  end

  def actions
    show_controlls.select { |control| control.action? }
  end

  def links
    show_controlls.select { |control| control.link_to? }
  end

  private

  # In development and test environments we should show the invalid field errors
  def should_display_invalid_fields_errors?
    (Rails.env.development? || Rails.env.test?) && @resource.invalid_fields.present?
  end

  def has_one_field?
    field.present? and field.instance_of? Avo::Fields::HasOneField
  end

  def show_controlls
    @show_controlls ||= resource.render_show_controls
  end
end
