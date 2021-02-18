# frozen_string_literal: true

class Avo::TableRowComponent < ViewComponent::Base
  def initialize(resource: resource, reflection: nil)
    @resource = resource
    @reflection = reflection
  end
end
