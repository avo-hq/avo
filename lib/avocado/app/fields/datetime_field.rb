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

        @picker_format = args[:picker_format].present? ? args[:picker_format] : 'Y-m-d G:i:S K'
        @format = args[:format].present? ? args[:format] : 'YYYY-MM-DD hh:mm:ss A'
      end

      def hydrate_resource(model, resource, view)
        {
          picker_format: @picker_format,
          format: @format,
          enable_time: true,
        }
      end
    end
  end
end
