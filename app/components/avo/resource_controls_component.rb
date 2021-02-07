# frozen_string_literal: true

module Avo
  class ResourceControlsComponent < ViewComponent::Base
    attr_reader :resource

    def initialize(resource: resource)
      @resource = resource
    end
  end
end
