# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, related_resource: nil, reflection: nil, parent_model: nil)
    @resources = resources
    @related_resource = related_resource
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
  end
end
