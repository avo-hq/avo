# frozen_string_literal: true

class Avo::Index::GridItemComponent < ViewComponent::Base
  include Avo::ResourcesHelper

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
end
