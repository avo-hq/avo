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
  end

  def before_render
    @display_breadcrumbs = @reflection.blank? || (@reflection.present? && !helpers.turbo_frame_request?)
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

    # Return to the current url if it doesn't include turbo_frame
    # When coming from a turbo frame, we don't want to return to that exact frame
    # for example when editing a has_one field we want to return to the parent frame
    # not the frame of the has_one field.
    args[:return_to] = request.url unless request.url.include?("turbo_frame=")

    helpers.edit_resource_path(record: @resource.record, resource: @resource, **args)
  end

  def controls
    @resource.render_show_controls
  end

  def linkable?
    has_one_field? && field&.linkable?
  end

  def linkable_url
    return unless linkable? && params[:turbo_frame].present?

    field.frame_url(add_turbo_frame: false)
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
