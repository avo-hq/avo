# frozen_string_literal: true

class Avo::EmptyStateComponent < ViewComponent::Base
  def initialize(resource_name: nil, related_name: nil, view_type: :table, add_background: false)
    @view_type = view_type
    @related_name = related_name
    @resource_name = resource_name
    @add_background = add_background
  end

  def message
    translation_tag = @related_name.present? ? 'avo.no_related_item_found' : 'avo.no_item_found'
    helpers.t translation_tag, item: @resource_name
  end

  def view_type_svg
    return "grid-empty-state" if @view_type.to_sym == :grid

    "table-empty-state"
  end
end
