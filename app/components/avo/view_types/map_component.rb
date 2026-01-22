# frozen_string_literal: true

# Render a map view for a list of resources, where each resource is
# expected to have an attribute/attribute set representing its location.
class Avo::ViewTypes::MapComponent < Avo::ViewTypes::BaseViewTypeComponent
  attr_reader :resources

  delegate :js_map, to: :helpers

  def grid_layout_classes
    return unless render_table?

    if horizontal_layout?
      "grid-flow-row sm:grid-flow-col grid-rows-1 auto-cols-fr"
    elsif vertical_layout?
      "grid-flow-row grid-cols-1"
    end
  end

  def horizontal_layout?
    %i[left right].include?(map_position)
  end

  def vertical_layout?
    %i[bottom top].include?(map_position)
  end

  def map_component_order_class
    if render_table? && table_positioned_at_the_start?
      "order-last"
    else
      "order-first"
    end
  end

  def table_component_order_class
    if table_positioned_at_the_start?
      "order-first"
    else
      "order-last"
    end
  end

  def table_positioned_at_the_start?
    %i[right bottom].include?(map_position)
  end

  def map_position
    map_options.dig(:map, :position)
  end

  def layout_horizontal?
    %i[left right].include?(map_position)
  end

  def layout_vertical?
    !layout_horizontal?
  end

  def resource_location_markers
    # If we have no proc and no default location method, don't try to create markers
    return [] unless resource_mappable?

    records_markers = resources
      .map do |resource|
        Avo::ExecutionContext.new(target: marker_proc, record: resource.record).handle
      end
      .compact
      .filter do |coordinates|
        coordinates[:latitude].present? && coordinates[:longitude].present?
      end

    return records_markers if map_options[:extra_markers].nil?

    records_markers + Avo::ExecutionContext.new(target: map_options[:extra_markers]).handle
  end

  def resource_mapkick_options
    options = map_options[:mapkick_options] || {}

    options[:height] = if layout_horizontal?
      "100%"
    else
      "26rem"
    end

    options[:style] ||= "mapbox://styles/mapbox/light-v11"

    options
  end

  def render_table?
    map_options.dig(:table, :visible)
  end

  private

  def default_record_marker_proc
    lambda {
      {
        latitude: record.coordinates.first,
        longitude: record.coordinates.last
      }
    }
  end

  def map_options
    @resource.map_view || {}
  end

  def marker_proc
    map_options[:record_marker] || default_record_marker_proc
  end

  def resource_mappable?
    map_options[:record_marker].present? || map_options[:extra_markers].present? || @resources.first.record.respond_to?(:coordinates)
  end
end
