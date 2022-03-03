# frozen_string_literal: true

class Avo::Index::Ordering::ButtonsComponent < Avo::Index::Ordering::BaseComponent
  def initialize(resource: nil)
    @resource = resource
  end

  def render?
    can_order_any?
  end

  def can_order_any?
    order_actions.present?
  end

  def always_visible?
    @resource.class.ordering[:always_visible]
  end
end
