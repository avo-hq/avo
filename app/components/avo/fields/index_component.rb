# frozen_string_literal: true

class Avo::Fields::IndexComponent < ViewComponent::Base
  include Avo::ResourcesHelper

  def initialize(field: nil, resource: nil, index: 0, parent_model: nil)
    @field = field
    @resource = resource
    @index = index
    @parent_model = parent_model
  end

  def resource_path
    if @parent_model.present?
      helpers.resource_path(@resource.model, via_resource_class: @parent_model.class, via_resource_id: @parent_model.id)
    else
      helpers.resource_path(@resource.model)
    end
  end
end
