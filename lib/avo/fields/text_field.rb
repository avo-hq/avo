module Avo
  module Fields
    class TextField < BaseField
      attr_reader :link_to_resource
      attr_reader :as_html

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
        @as_html = args[:as_html].present? ? args[:as_html] : false
      end
    end
  end
end
