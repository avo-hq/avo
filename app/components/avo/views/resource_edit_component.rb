# frozen_string_literal: true

class Avo::Views::ResourceEditComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(resource: nil, model: nil, actions: [], view: :edit)
    @resource = resource
    @model = model
    @actions = actions
    @view = view
  end

  def title
    @resource.default_panel_name
  end

  def back_path
    return default_view if via_resource?
    return resources_path if via_index?

    if is_edit? && !Avo.configuration.skip_show_view # via resource show or edit page
      return helpers.resource_path(model: @resource.model, resource: @resource)
    end

    resources_path
  end

  def resources_path
    helpers.resources_path(resource: @resource)
  end

  def default_view
    model = params[:via_resource_class] || params[:via_relation_class]

    if Avo.configuration.skip_show_view
      helpers.edit_resource_path(model: relation_resource.model, resource: relation_resource)
    else
      helpers.resource_path(model: model.safe_constantize, resource: relation_resource, resource_id: params[:via_resource_id])
    end
  end

  def can_see_the_destroy_button?
    return super if Avo.configuration.skip_show_view && view == :edit

    false
  end

  # The save button is dependent on the edit? policy method.
  # The update? method should be called only when the user clicks the Save button so the developer gets access to the params from the form.
  def can_see_the_save_button?
    @resource.authorization.authorize_action @view, raise_exception: false
  end

  private

  def via_index?
    params[:via_view] == "index"
  end

  def is_edit?
    view.in?([:edit, :update])
  end

  def form_method
    return :put if is_edit?

    :post
  end

  def form_url
    if is_edit?
      helpers.resource_path(
        model: @resource.model,
        resource: @resource
      )
    else
      helpers.resources_path(
        resource: @resource,
        via_relation_class: params[:via_relation_class],
        via_relation: params[:via_relation],
        via_resource_id: params[:via_resource_id]
      )
    end
  end
end
