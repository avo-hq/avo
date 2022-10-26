# frozen_string_literal: true

class Avo::Index::GridItemComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :parent_resource

  def initialize(resource: nil, reflection: nil, parent_model: nil, parent_resource: nil)
    @resource = resource
    @reflection = reflection
    @grid_fields = resource.get_grid_fields
    @parent_model = parent_model
    @parent_resource = parent_resource
  end

  private

  def cover
    @grid_fields.cover_field
  end

  def title
    @grid_fields.title_field
  end

  def body
    @grid_fields.body_field
  end

  def resource_view_path
    args = {}

    if @parent_model.present?
      args = {
        via_resource_class: parent_resource.class.to_s,
        via_resource_id: @parent_model.id
      }
    end

    helpers.resource_view_path(model: @resource.model, resource: @resource, **args)
  end
end
