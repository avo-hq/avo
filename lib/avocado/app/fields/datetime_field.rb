require_relative 'date_field'

module Avocado
  module Fields
    class DatetimeField < DateField
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'datetime-field',
        }

        super(name, **args, &block)

        @picker_format = args[:picker_format].present? ? args[:picker_format] : 'Y-m-d H:i:S'
        @format = args[:format].present? ? args[:format] : 'YYYY-MM-DD hh:mm:ss A'
        @time_24hr = args[:time_24hr].present? ? args[:time_24hr] : false
        @timezone = args[:timezone].present? ? args[:timezone] : Rails.application.config.time_zone
      end

      def hydrate_field(fields, model, resource, view)
        {
          first_day_of_week: @first_day_of_week,
          picker_format: @picker_format,
          format: @format,
          placeholder: @placeholder,
          enable_time: true,
          time_24hr: @time_24hr,
          timezone: @timezone,
        }
      end
    end
  end
end
