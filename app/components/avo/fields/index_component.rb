# frozen_string_literal: true

class Avo::Fields::IndexComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :parent_resource
  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0, parent_model: nil, parent_resource: nil)
    @field = field
    @resource = resource
    @index = index
    @parent_model = parent_model
    @parent_resource = parent_resource
    @view = :index
  end

  def resource_view_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: @parent_resource.class,
        via_resource_id: @parent_model.id
      }
    end

    helpers.resource_view_path(model: @resource.model, resource: @resource, **args)
  end

  def field_wrapper_args
    {
      field: @field,
      resource: @resource
    }
  end
end
