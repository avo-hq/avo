# frozen_string_literal: true

class Avo::FiltersComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(filters: [], resource: nil, applied_filters: [])
    @filters = filters
    @resource = resource
    @applied_filters = applied_filters
  end

  def render?
    @filters.present?
  end
end
