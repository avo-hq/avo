# frozen_string_literal: true

class Avo::FiltersComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :filters, _Array(Avo::Filters::BaseFilter), default: [].freeze
  prop :resource, _Nilable(Avo::BaseResource)
  prop :applied_filters, Hash, default: {}.freeze
  prop :parent_record, _Nilable(_Any)

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
