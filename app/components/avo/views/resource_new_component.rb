# frozen_string_literal: true

class Avo::Views::ResourceNewComponent < ViewComponent::Base
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(
    resource: nil,
    model: nil
  )
    @resource = resource
    @model = model
  end

  def back_path
    if via_resource?
      helpers.resource_path(model: params[:via_relation_class].safe_constantize, resource: relation_resource, resource_id: params[:via_resource_id])
    else
      helpers.resources_path(resource: @resource)
    end
  end

  # The create button is dependent on the new? policy method.
  # The create? should be called only when the user clicks the Save button so the developers gets access to the params from the form.
  def can_see_the_save_button?
    @resource.authorization.authorize_action :new, raise_exception: false
  end

  private

  def via_resource?
    params[:via_relation_class].present? && params[:via_resource_id].present?
  end

  def relation_resource
    ::Avo::App.get_resource_by_model_name params[:via_relation_class].safe_constantize
  end
end
