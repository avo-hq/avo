module Avo
  module Dashboards
    class BaseDivider
      attr_reader :label
      attr_reader :invisible
      attr_reader :index

      include Avo::Fields::FieldExtensions::VisibleInDifferentViews

      class_attribute :id

      def initialize(label: nil, invisible: false, index: nil, **args)
        @label = label
        @invisible = invisible
        @index = index

        initialize_visibility args
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
