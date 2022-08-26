# frozen_string_literal: true

class Avo::FiltersComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(filters: [], resource: nil, applied_filters: [], parent_model: nil)
    @filters = filters
    @resource = resource
    @applied_filters = applied_filters
    @parent_model = parent_model
  end

  def render?
    @filters.present?
  end

  def reset_path
    # If come from a association page
    if @parent_model.present?
      helpers.related_resources_path(@parent_model, @parent_model, filters: nil, keep_query_params: true)
    else
      helpers.resources_path(resource: @resource, filters: nil, keep_query_params: true)
    end
  end
end
