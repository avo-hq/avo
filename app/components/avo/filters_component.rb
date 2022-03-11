# frozen_string_literal: true

class Avo::FiltersComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(filters: [], resource: nil)
    @filters = filters
    @resource = resource
  end

  def render?
    @filters.present?
  end
end
