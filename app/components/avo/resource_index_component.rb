# frozen_string_literal: true

module Avo
  class ResourceIndexComponent < ViewComponent::Base
    include Avo::ResourcesHelper
    include Avo::ApplicationHelper

    attr_reader :params

    def initialize(title: nil, resource: nil, resources: nil, models: nil, view_type: :table, params: nil)
      @title = title if title.present?
      @resource = resource if resource.present?
      @resources = resources if resources.present?
      @models = models if models.present?
      @view_type = view_type if view_type.present?
      @params = params if params.present?
    end
  end
end
