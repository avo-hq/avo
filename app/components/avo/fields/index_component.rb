# frozen_string_literal: true

class Avo::Fields::IndexComponent < Avo::BaseComponent
  include Avo::ResourcesHelper

  attr_reader :parent_resource
  attr_reader :view

  def initialize(field: nil, resource: nil, reflection: nil, index: 0, parent_model: nil, parent_resource: nil)
    @field = field
    @resource = resource
    @index = index
    @parent_model = parent_model
    @parent_resource = parent_resource
    @view = :index
    @reflection = reflection
  end

  def resource_view_path
    args = {}

    if @parent_model.present?
      via_resource_id = if @parent_model.respond_to? :to_param
        @parent_model.to_param
      else
        @parent_model.id
      end

      args = {
        via_resource_class: @parent_resource.class,
        via_resource_id: via_resource_id
      }
    end

    helpers.resource_view_path(model: @resource.model, resource: parent_or_child_resource, **args)
  end

  def field_wrapper_args
    {
      field: @field,
      resource: @resource
    }
  end
end
