# frozen_string_literal: true

module Avo
  class ResourceIndexComponent < ViewComponent::Base
    include Avo::ResourcesHelper
    include Avo::ApplicationHelper

    attr_reader :params

    def initialize(title: nil, resource: nil, resources: nil, models: nil, view_type: :table, params: nil)
      @title = title
      @resource = resource
      @resources = resources
      @models = models
      @view_type = view_type
      @params = params
    end
  end
end
