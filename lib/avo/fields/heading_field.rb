module Avo
  module Fields
    class HeadingField < BaseField
      attr_reader :as_html

      def initialize(content, **args, &block)
        args[:updatable] = false

        super(content, **args, &block)

        hide_on :index

        @as_html = args[:as_html].present? ? args[:as_html] : false
      end

      def id
        "heading_#{name.to_s.parameterize.underscore}"
      end
    end
  end
end
