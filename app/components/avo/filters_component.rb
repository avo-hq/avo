# frozen_string_literal: true

class Avo::FiltersComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(filters: [], resource: nil, applied_filters: [], parent_record: nil)
    @filters = filters
    @resource = resource
    @applied_filters = applied_filters
    @parent_record = parent_record
  end

  def render?
    @filters.present?
  end

  def reset_path
    # If come from a association page
    if @parent_record.present?
      helpers.related_resources_path(@parent_record, @parent_record, filters: nil, reset_filter: true, keep_query_params: true)
    else
      helpers.resources_path(resource: @resource, filters: nil, reset_filter: true, keep_query_params: true)
    end
  end
end
