require "securerandom"

module Avo
  module Fields
    class HeadingField < BaseField
      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      attr_reader :as_html

      def initialize(id, **args, &block)
        args[:updatable] = false
        @label = args[:label] || id.to_s.humanize

        super(id, **args, &block)

        hide_on :index

        @as_html = args[:as_html].presence || false
      end

      def id
        "heading_#{name.to_s.parameterize.underscore}"
      end

      def value
        @block.present? ? execute_context(@block) : @label
      end
    end
  end
end
