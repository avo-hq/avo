# frozen_string_literal: true

class Avo::Items::VisibleItemsComponent < ViewComponent::Base
  def initialize(resource:, item:, view:, form:, field_component_extra_args: {})
    @resource = resource
    @item = item
    @view = view
    @form = form
    @field_component_extra_args = field_component_extra_args
  end
end
