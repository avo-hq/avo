# frozen_string_literal: true

class Avo::TableRowComponent < ViewComponent::Base
  def initialize(resource: resource, reflection: nil, parent_model: nil)
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
  end
end
