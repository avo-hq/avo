# frozen_string_literal: true

class Avo::Views::ResourceShowComponent < Avo::ResourceComponent
  include Avo::ApplicationHelper

  attr_reader :display_breadcrumbs

  prop :resource
  prop :reflection
  prop :parent_resource
  prop :parent_record
  prop :resource_panel, reader: :public
  prop :actions, default: [].freeze, reader: :public

  def after_initialize
    @view = Avo::ViewInquirer.new("show")
    @display_breadcrumbs = @reflection.blank?
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
    # The `return_to` param takes precedence over anything else.
    return params[:return_to] if params[:return_to].present?

    if via_resource?
      helpers.resource_path(resource: association_resource, resource_id: params[:via_record_id])
    else
      helpers.resources_path(resource: @resource, **keep_referrer_params)
    end
  end

  def edit_path
    args = if via_resource?
      {
        via_resource_class: params[:via_resource_class],
        via_record_id: params[:via_record_id]
      }
    elsif @parent_resource.present?
      {
        via_resource_class: @parent_resource.class,
        via_record_id: @parent_record.to_param
      }
    else
      {}
    end

    # Pass the return_to param to the edit path so the chain of navigation is kept.
    args[:return_to] = params[:return_to] if params[:return_to].present?

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
