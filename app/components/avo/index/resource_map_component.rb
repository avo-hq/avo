# frozen_string_literal: true

class Avo::Index::ResourceMapComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, pagy: nil, query: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
    @pagy = pagy
    @query = query
  end
end
