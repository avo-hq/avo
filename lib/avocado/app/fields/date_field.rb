require_relative 'text_field'

module Avocado
  module Fields
    class DateField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'date-field',
          computable: true,
        }

        super(name, **args, &block)

        @firstDayOfWeek = args[:firstDayOfWeek].present? ? args[:firstDayOfWeek].to_i : 0
        @pickerFormat = args[:pickerFormat].present? ? args[:pickerFormat] : 'Y-m-d'
        @format = args[:format].present? ? args[:format] : 'YYYY-MM-DD'
      end

      def hydrate_resource(model, resource, view)
        {
          firstDayOfWeek: @firstDayOfWeek,
          pickerFormat: @pickerFormat,
          format: @format,
        }
      end
    end
  end
end
