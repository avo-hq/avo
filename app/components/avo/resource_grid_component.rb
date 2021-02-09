# frozen_string_literal: true

module Avo
  class ResourceGridComponent < ViewComponent::Base
    attr_reader :resources
    attr_reader :resource
    attr_reader :reflection

    def initialize(resources: nil, resource: nil, reflection: nil)
      @resources = resources
      @resource = resource
      @reflection = reflection
    end
  end
end
