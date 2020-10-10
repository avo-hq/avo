require_relative 'text_field'

module Avo
  module Fields
    class DateField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'datetime-field',
        }

        super(name, **args, &block)

        @first_day_of_week = args[:first_day_of_week].present? ? args[:first_day_of_week].to_i : 0
        @picker_format = args[:picker_format].present? ? args[:picker_format] : 'Y-m-d'
        @format = args[:format].present? ? args[:format] : 'YYYY-MM-DD'
        @placeholder = args[:placeholder].present? ? args[:placeholder] : ''
        @relative = args[:relative].present? ? args[:relative] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          first_day_of_week: @first_day_of_week,
          picker_format: @picker_format,
          format: @format,
          placeholder: @placeholder,
          relative: @relative,
        }
      end
    end
  end
end
