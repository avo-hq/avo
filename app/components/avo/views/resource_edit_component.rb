# frozen_string_literal: true

class Avo::Views::ResourceEditComponent < Avo::ResourceComponent
  include Avo::ResourcesHelper
  include Avo::ApplicationHelper

  def initialize(resource: nil)
    @resource = resource
  end

  def back_path
    if via_resource?
      helpers.resource_path(model: params[:via_resource_class].safe_constantize, resource: relation_resource, resource_id: params[:via_resource_id])
    else
      helpers.resource_path(model: @resource.model, resource: @resource)
    end
  end

  private

  def via_resource?
    params[:via_resource_class].present? && params[:via_resource_id].present?
  end
end
