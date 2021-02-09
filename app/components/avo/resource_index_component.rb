# frozen_string_literal: true

module Avo
  class ResourceIndexComponent < ViewComponent::Base
    include Avo::ResourcesHelper
    include Avo::ApplicationHelper

    attr_reader :view_type
    attr_reader :available_view_types
    attr_reader :via_resource_name
    attr_reader :via_resource_id
    attr_reader :via_relation
    attr_reader :via_relation_param

    def initialize(
      resource: nil,
      resources: nil,
      models: [],
      pagy: nil,
      index_params: {},
      reflection: nil,
      frame_name: ''
    )
      @resource = resource
      @resources = resources
      @models = models
      @pagy = pagy
      @index_params = index_params
      @reflection = reflection
      @frame_name = frame_name
    end

    def title
      if @reflection.present?
        @reflection.plural_name.capitalize
      else
        @resource.plural_name
      end
    end

    def view_type
      @index_params[:view_type]
    end

    def available_view_types
      @index_params[:available_view_types]
    end

    def can_attach?
      @reflection.present? && @reflection.is_a?(::ActiveRecord::Reflection::HasManyReflection) && @models.present?
    end

    def can_detach?
      @reflection.present? && @reflection.is_a?(::ActiveRecord::Reflection::HasOneReflection) && @models.present?
    end
  end
end
