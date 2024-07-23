# frozen_string_literal: true

class Avo::PaginatorComponent < ViewComponent::Base
  attr_reader :pagy
  attr_reader :turbo_frame
  attr_reader :index_params
  attr_reader :resource
  attr_reader :parent_record
  attr_reader :discreet_pagination

  def initialize(resource: nil, parent_record: nil, pagy: nil, turbo_frame: nil, index_params: nil, discreet_pagination: nil)
    @pagy = pagy
    @turbo_frame = turbo_frame
    @index_params = index_params
    @resource = resource
    @parent_record = parent_record
    @discreet_pagination = discreet_pagination
  end

  def change_items_per_page_url(option)
    if parent_record.present?
      helpers.related_resources_path(parent_record, parent_record, per_page: option, keep_query_params: true, page: 1)
    else
      helpers.resources_path(resource: resource, per_page: option, keep_query_params: true, page: 1)
    end
  end

  def render?
    return false if discreet_pagination && pagy.pages <= 1

    if defined?(@pagy.limit)
      @pagy.limit > 0
    else
      @pagy&.items > 0
    end
  end

  def per_page_options
    @per_page_options ||= begin
      options = [*Avo.configuration.per_page_steps, Avo.configuration.per_page.to_i, index_params[:per_page].to_i]

      if parent_record.present?
        options.prepend Avo.configuration.via_per_page
      end

      options.sort.uniq
    end
  end

  def pagy_major_version
    return nil unless defined?(Pagy::VERSION)
    version = Pagy::VERSION&.split(".")&.first&.to_i

    return "8-or-more" if version >= 8

    version
  end
end
