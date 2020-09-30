module Avo
  module Fields
    class SelectField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'select-field',
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : {}
        @enum = args[:enum].present? ? args[:enum] : nil
        @display_value = args[:display_value].present? ? args[:display_value] : false
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : 'Choose an option'
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
          enum: @enum,
          display_value: @display_value,
          placeholder: @placeholder,
        }
      end
    end
  end
end
