# frozen_string_literal: true

module Avo
  module Index
    # Render a map view for a list of resources, where each resource is
    # expected to have an attribute/attribute set representing its location.
    class ResourceMapComponent < ViewComponent::Base
      attr_reader :resources

      def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, pagy: nil, query: nil)
        super
        @resources = resources
        @resource = resource
        @reflection = reflection
        @parent_model = parent_model
        @parent_resource = parent_resource
        @pagy = pagy
        @query = query
      end

      def grid_layout_classes
        return unless render_table?

        if table_positioned_horizontally
          "grid-flow-row sm:grid-flow-col grid-rows-1 auto-cols-fr"
        elsif table_positioned_vertically
          "grid-flow-row grid-cols-1"
        end
      end

      def table_positioned_horizontally
        %i[left right].include?(map_view_table_layout)
      end

      def table_positioned_vertically
        %i[bottom top].include?(map_view_table_layout)
      end

      def map_component_order_class
        if render_table? && table_positioned_at_the_start
          "order-last"
        else
          "order-first"
        end
      end

      def table_component_order_class
        if table_positioned_at_the_start
          "order-first"
        else
          "order-last"
        end
      end

      def table_positioned_at_the_start
        %i[left top].include?(map_view_table_layout)
      end

      def map_view_table_layout
        map_options.dig(:table, :layout)
      end

      def resource_location_markers
        # If we have no proc and no default location method, don't try to create markers
        return [] unless resource_mappable?

        resources
          .map do |resource|
            Avo::Hosts::ResourceRecordHost.new(block: marker_proc, resource: resource, record: resource.record).handle
          end
          .compact
          .filter do |coordinates|
            coordinates[:latitude].present? && coordinates[:longitude].present?
          end
      end

      def resource_mapkick_options
        map_options[:mapkick_options] || {}
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
        map_options[:record_marker].present? || @resources.first.record.respond_to?(:coordinates)
      end
    end
  end
end
