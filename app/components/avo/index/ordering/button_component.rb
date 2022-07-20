# frozen_string_literal: true

class Avo::Index::Ordering::ButtonComponent < Avo::Index::Ordering::BaseComponent
  attr_accessor :resource
  attr_accessor :reflection
  attr_accessor :direction
  attr_accessor :svg

  def initialize(resource:, direction:, svg: nil,  reflection: nil)
    @resource = resource
    @reflection = reflection
    @direction = direction
    @svg = svg
  end

  def render?
    order_actions[direction].present?
  end

  def order_path(args)
    Avo::App.view_context.avo.reorder_order_path(resource.route_key, resource.model.id, **args)
  end
end
