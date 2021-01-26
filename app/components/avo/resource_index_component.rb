# frozen_string_literal: true

module Avo
  class ResourceIndexComponent < ViewComponent::Base
    include Avo::ResourcesHelper
    include Avo::ApplicationHelper

    def initialize(title: nil, resource: nil, resources: nil, models: nil, view_type: :table, via_relation: nil)
      @title = title if title.present?
      @resource = resource if resource.present?
      @resources = resources if resources.present?
      @models = models if models.present?
      @view_type = view_type if view_type.present?
      @via_relation = via_relation if via_relation.present?
    end

    def params
      @params
    end

    def request
      @request
    end
  end
end
