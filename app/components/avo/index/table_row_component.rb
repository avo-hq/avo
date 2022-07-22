# frozen_string_literal: true

class Avo::Index::TableRowComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  def initialize(resource: nil, reflection: nil, parent_model: nil, parent_resource: nil)
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
  end
end
