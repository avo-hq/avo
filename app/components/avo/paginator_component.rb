# frozen_string_literal: true

class Avo::PaginatorComponent < ViewComponent::Base
  attr_reader :pagy
  attr_reader :turbo_frame
  attr_reader :index_params
  attr_reader :resource
  attr_reader :parent_model
  attr_reader :discreet_pagination

  def initialize(resource: nil, parent_model: nil, pagy: nil, turbo_frame: nil, index_params: nil, discreet_pagination: nil)
    @pagy = pagy
    @turbo_frame = turbo_frame
    @index_params = index_params
    @resource = resource
    @parent_model = parent_model
    @discreet_pagination = discreet_pagination
  end

  def change_items_per_page_url(option)
    if parent_model.present?
      helpers.related_resources_path(parent_model, parent_model, per_page: option, keep_query_params: true, page: 1)
    else
      helpers.resources_path(resource: resource, per_page: option, keep_query_params: true, page: 1)
    end
  end
end
