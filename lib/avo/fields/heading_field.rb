require "securerandom"

module Avo
  module Fields
    class HeadingField < BaseField
      attr_reader :as_html

      def initialize(id, **args, &block)
        args[:updatable] = false
        @label = args[:label] || id.to_s.humanize

        super(id, **args, &block)

        # this field is not used to update anything
        @for_presentation_only = true

        hide_on :index

        @as_html = args[:as_html].presence || false
      end

      def id
        "heading_#{name.to_s.parameterize.underscore}"
      end

      def value
        block.present? ? execute_block : @label
      end
    end
  end
end
