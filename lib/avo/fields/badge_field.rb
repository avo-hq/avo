module Avo
  module Fields
    class BadgeField < BaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
      end

      def options_for_filter
        @options.values.flatten.uniq
      end
    end
  end
end
