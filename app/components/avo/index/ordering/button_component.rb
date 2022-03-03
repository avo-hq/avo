# frozen_string_literal: true

class Avo::Index::Ordering::ButtonComponent < Avo::Index::Ordering::BaseComponent
  attr_reader :resource
  attr_reader :direction
  attr_reader :svg

  def initialize(resource: nil, direction: nil, svg: nil)
    @resource = resource
    @direction = direction
    @svg = svg
  end

  def render?
    order_actions[direction].present?
  end

  def order_path(args)
    path = "#{::Avo::App.root_path}/resources/#{resource.route_key}/#{resource.model.id}/order"

    if args.present?
      string_args = args.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      path = "#{path}?#{string_args}"
    end

    path
  end
end
