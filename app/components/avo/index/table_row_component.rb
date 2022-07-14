# frozen_string_literal: true

class Avo::Index::TableRowComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  def initialize(resource: nil, related_resource: nil, reflection: nil, parent_model: nil)
    @resource = resource
    @related_resource = related_resource
    @reflection = reflection
    @parent_model = parent_model
  end
end
