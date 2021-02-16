# frozen_string_literal: true

class Avo::TableRowComponent < ViewComponent::Base
  attr_reader :resource
  attr_reader :reflection

  def initialize(resource: resource, reflection: nil)
    @resource = resource
    @reflection = reflection
  end
end
