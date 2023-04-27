# frozen_string_literal: true

module Avo
  module Index
    # Render a map view for a list of resources, where each resource is
    # expected to have an attribute/attribute set representing its location.
    class ResourceMapComponent < ViewComponent::Base
      def initialize(resources: nil,
                     resource: nil,
                     reflection: nil,
                     parent_model: nil,
                     parent_resource: nil,
                     pagy: nil,
                     query: nil)
        super
        @resources = resources
        @resource = resource
        @reflection = reflection
        @parent_model = parent_model
        @parent_resource = parent_resource
        @pagy = pagy
        @query = query
      end

      def map_view_table_layout_class
        return '' unless render_map_view_table?

        table_layout_classes = {
          bottom: 'table-bottom',
          left: 'table-left',
          right: 'table-right',
          top: 'table-top'
        }

        table_layout_classes[map_options.dig(:table, :layout)]
      end

      def resource_location_markers
        # If we have no proc and no default location method, don't try to create markers
        return [] unless resource_mappable?

        @resources.map do |marker_resource|
          coordinates = marker_proc.call(record: marker_resource.record)

          next unless coordinates[:latitude].present? && coordinates[:longitude].present?

          coordinates
        end.compact
      end

      def resource_mapkick_options
        map_options[:mapkick_options] || {}
      end

      def render_map_view_table?
        map_options.dig(:table, :visible)
      end

      private

      def default_record_marker_proc
        lambda { |record:|
          {
            latitude: record.coordinates.first,
            longitude: record.coordinates.last
          }
        }
      end

      def map_options
        @resource.map || {}
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
