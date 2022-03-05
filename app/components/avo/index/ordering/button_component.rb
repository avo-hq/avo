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
    if reflection.present?
      path = "#{::Avo::App.root_path}/resources/#{reflection_parent_resource.route_key}/#{params[:id]}/#{field.id}/#{resource.model.id}/order"
    else
      path = "#{::Avo::App.root_path}/resources/#{resource.route_key}/#{resource.model.id}/order"
    end

    if args.present?
      string_args = args.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      path = "#{path}?#{string_args}"
    end

    path
  end
end
