# frozen_string_literal: true

class Avo::Index::ResourceGridComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
  end
end
