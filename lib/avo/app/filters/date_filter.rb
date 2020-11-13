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
          # format: 'YYYY-MM-DD',
          placeholder: '',
          # enable_time: false,
          # time_24hr: false,
          # timezone: Rails.application.config.time_zone,
          relative: false,
        }

        # defaults.merge!({ picker_format: 'Y-m-d H:i:S', format: 'YYYY-MM-DD hh:mm:ss A', }) if configuration['enable_time'.to_sym] === true

        return configuration.reverse_merge!(defaults) if defined? configuration

        defaults
      end
    end
  end
end
