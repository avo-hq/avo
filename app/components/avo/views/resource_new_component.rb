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
      helpers.resource_path(params[:via_relation_class].safe_constantize, for_resource: relation_resource, resource_id: params[:via_resource_id])
    else
      helpers.resources_path(@resource.model, for_resource: @resource)
    end
  end

  private

  def via_resource?
    params[:via_relation_class].present? && params[:via_resource_id].present?
  end

  def relation_resource
    ::Avo::App.get_resource_by_model_name params[:via_relation_class].safe_constantize
  end
end
