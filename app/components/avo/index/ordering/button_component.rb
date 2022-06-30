# frozen_string_literal: true

class Avo::Index::Ordering::ButtonComponent < Avo::Index::Ordering::BaseComponent
  delegate :view_context, to: ::Avo::App

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
     if reflection.present?
      view_context.avo.associations_order_path(reflection_parent_resource.route_key, params[:id], field.id, resource.model.id, **args)
    else
      view_context.avo.resources_order_path(resource.route_key, resource.model.id, **args)
    end
  end
end
