# frozen_string_literal: true

class Avo::Index::Ordering::ButtonsComponent < Avo::Index::Ordering::BaseComponent
  def initialize(resource: nil, reflection: nil, view_type: nil)
    @resource = resource
    @reflection = reflection
    @view_type = view_type
  end

  def render?
    has_with_trial(:resource_ordering) && can_order_any? && view_type_is_table? && enabled_in_view?
  end

  private

  def can_order_any?
    order_actions.present?
  end

  def view_type_is_table?
    @view_type.to_sym == :table
  end

  def display_inline?
    ordering[:display_inline]
  end

  def enabled_in_view?
    in_association = @reflection.present?

    if in_association
      visible_on_option.include? :association
    else
      visible_on_option.include? :index
    end
  end

  def visible_on_option
    [ordering[:visible_on]].flatten
  end

  def ordering
    @resource.class.ordering
  end
end
