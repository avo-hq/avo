# frozen_string_literal: true

class Avo::ResourceTableComponent < ViewComponent::Base
  def initialize(resources: nil, resource: nil, reflection: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
  end
end
