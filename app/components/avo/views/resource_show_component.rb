# frozen_string_literal: true

class Avo::Views::ResourceShowComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(resource: nil, reflection: nil, parent_model: nil, resource_panel: nil, actions: [])
    @resource = resource
    @reflection = reflection
    @resource_panel = resource_panel
    @actions = actions

    split_panel_fields
  end

  def title
    if @reflection.present?
      return field.name if has_one_field?
      reflection_resource.name
    else
      @resource.panels.first[:name]
    end
  end

  def back_path
    if via_resource?
      helpers.resource_path(model: params[:via_resource_class].safe_constantize, resource: relation_resource, resource_id: params[:via_resource_id])
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

  def tabs
    @resource.tabs_holder
  end

  # def active_tab_name
  #   params[:active_tab] || tabs.first.name
  # end

  # def active_tab
  #   tab_by_name active_tab_name
  # end

  private

  def tab_by_name(name = nil)
    @resource.tabs_holder.find do |tab|
      tab.name.to_s == name.to_s
    end
  end

  # In development and test environments we shoudl show the invalid field errors
  def should_display_invalid_fields_errors?
    (Rails.env.development? || Rails.env.test?) && @resource.invalid_fields.present?
  end

  def has_one_field?
    field.present? and field.instance_of? Avo::Fields::HasOneField
  end
end
