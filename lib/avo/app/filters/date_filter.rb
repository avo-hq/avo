require_relative '../filter'

module Avo
  module Filters
    class DateFilter < Avo::Filter
      def initialize
        @component ||= 'date-filter'

        super
      end

      def filter_configuration
        defaults = {
          range: false,
          first_day_of_week: 0,
          picker_format: 'Y-m-d',
          placeholder: '',
        }

        return configuration.reverse_merge!(defaults) if defined? configuration

        defaults
      end
    end
  end
end
