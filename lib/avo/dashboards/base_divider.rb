module Avo
  module Dashboards
    class BaseDivider
      include Avo::Concerns::VisibleInDashboard

      attr_reader :dashboard
      attr_reader :label
      attr_reader :invisible
      attr_reader :index
      attr_reader :visible

      class_attribute :id

      def initialize(dashboard: nil, label: nil, invisible: false, index: nil, visible: true)
        @dashboard = dashboard
        @label = label
        @invisible = invisible
        @index = index
        @visible = visible
      end

      def is_divider?
        true
      end

      def is_card?
        false
      end

      def call_block
        ::Avo::Hosts::CardVisibility.new(block: visible, card: self, parent: dashboard).handle
      end
    end
  end
end
