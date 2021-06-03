# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, fields: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @fields = fields
  end
end
