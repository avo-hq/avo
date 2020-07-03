require_relative 'field'

module Avocado
  module Fields
    class SelectField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'select-field',
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : {}
        @display_with_value = args[:display_with_value].present? ? args[:display_with_value] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
          display_with_value: @display_with_value,
          placeholder: 'Choose an option',
        }
      end
    end
  end
end
