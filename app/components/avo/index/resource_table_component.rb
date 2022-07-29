# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
  end
end
