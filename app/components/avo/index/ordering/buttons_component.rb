# frozen_string_literal: true

class Avo::Index::Ordering::ButtonsComponent < Avo::Index::Ordering::BaseComponent
  def initialize(resource: nil, reflection: nil, view_type: nil)
    @resource = resource
    @reflection = reflection
    @view_type = view_type
  end

  def render?
    view_type_is_table? && can_order_any? && has_with_trial(:resource_ordering)
  end

  def can_order_any?
    order_actions.present?
  end

  def view_type_is_table?
    @view_type.to_sym == :table
  end

  def display_inline?
    @resource.class.ordering[:display_inline]
  end

  def visible_in_view?
    @resource.class.ordering[:display_inline]
  end
end
