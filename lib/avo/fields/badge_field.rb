module Avo
  module Fields
    class BadgeField < BaseField
      attr_reader :options

      def initialize(id, **args, &)
        super

        hide_on [:edit, :new]

        default_options = {info: :info, success: :success, danger: :danger, warning: :warning, neutral: :neutral}
        @options = args[:options].present? ? default_options.merge(args[:options]) : default_options
        @enum = args[:enum]

        if @enum
          @options_for_filter = options.transform_values do |value|
            if value.is_a? Array
              value.map { |v| @enum[v.to_s] }
            else
              @enum[value.to_s] || value
            end
          end
        end
      end
    end
  end
end
