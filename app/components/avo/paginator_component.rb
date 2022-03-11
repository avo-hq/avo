# frozen_string_literal: true

class Avo::PaginatorComponent < ViewComponent::Base
  attr_reader :pagy
  attr_reader :turbo_frame
  attr_reader :index_params
  attr_reader :resource
  attr_reader :parent_resource

  def initialize(resource: nil, parent_resource: nil, pagy:, turbo_frame:, index_params:)
    @pagy = pagy
    @turbo_frame = turbo_frame
    @index_params = index_params
    @resource = resource
    @parent_resource = parent_resource
  end
end
