# frozen_string_literal: true

class Avo::Fields::ShowComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  attr_reader :view

  def initialize(field: nil, resource: nil, index: 0)
    @field = field
    @resource = resource
    @index = index
    @view = :show
  end
end
