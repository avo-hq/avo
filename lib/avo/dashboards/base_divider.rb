module Avo
  module Dashboards
    class BaseDivider
      attr_reader :label
      attr_reader :invisible

      class_attribute :id

      def initialize(label: nil, invisible: false)
        @label = label
        @invisible = invisible
      end

      def is_divider?
        true
      end

      def is_card?
        false
      end
    end
  end
end
