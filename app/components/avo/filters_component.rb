# frozen_string_literal: true

class Avo::FiltersComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :filters, default: [].freeze
  prop :resource
  prop :applied_filters, default: {}.freeze
  prop :parent_record

  def render?
    @filters.present?
  end

  def reset_path
    # If come from a association page
    if @parent_record.present?
      helpers.related_resources_path(@parent_record, @parent_record, encoded_filters: nil, reset_filter: true, keep_query_params: true)
    else
      helpers.resources_path(resource: @resource, encoded_filters: nil, reset_filter: true, keep_query_params: true)
    end
  end
end
