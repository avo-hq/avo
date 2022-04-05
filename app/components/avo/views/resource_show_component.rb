# frozen_string_literal: true

class Avo::Views::ResourceShowComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  attr_reader :fields_by_panel, :has_one_panels, :has_many_panels, :has_as_belongs_to_many_panels

  def initialize(resource: nil, reflection: nil, parent_model: nil, resource_panel: nil, actions: [])
    @resource = resource
    @reflection = reflection
    @resource_panel = resource_panel
    @actions = actions

    split_panel_fields
  end

  def title
    if @reflection.present?
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

  def detach_path
    helpers.resource_detach_path(params[:resource_name], params[:id], @reflection.name.to_s, @resource.model.id)
  end

  def destroy_path
    helpers.resource_path(model: @resource.model, resource: @resource)
  end

  def can_detach?
    authorize_association_for("detach")
  end

  def can_see_the_edit_button?
    @resource.authorization.authorize_action(:edit, raise_exception: false)
  end

  def can_see_the_destroy_button?
    @resource.authorization.authorize_action(:destroy, raise_exception: false)
  end

  private

  def via_resource?
    params[:via_resource_class].present? && params[:via_resource_id].present?
  end

  def split_panel_fields
    @fields_by_panel = {}
    @has_one_panels = []
    @has_many_panels = []
    @has_as_belongs_to_many_panels = []

    @resource.get_fields.each do |field|
      case field.class.to_s
      when "Avo::Fields::HasOneField"
        @has_one_panels << field
      when "Avo::Fields::HasManyField"
        @has_many_panels << field
      when "Avo::Fields::HasAndBelongsToManyField"
        @has_as_belongs_to_many_panels << field
      else
        @fields_by_panel[field.panel_name] ||= []
        @fields_by_panel[field.panel_name] << field
      end
    end
  end

  # In development and test environments we shoudl show the invalid field errors
  def should_display_invalid_fields_errors?
    (Rails.env.development? || Rails.env.test?) && @resource.invalid_fields.present?
  end
end
