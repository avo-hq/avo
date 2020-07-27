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
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : 'Choose an option'
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
          display_with_value: @display_with_value,
          placeholder: @placeholder,
        }
      end
    end
  end
end
