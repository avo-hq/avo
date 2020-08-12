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
        @display_labels = args[:display_labels].present? ? args[:display_labels] : false
        @placeholder = args[:placeholder].present? ? args[:placeholder].to_s : 'Choose an option'
      end

      def hydrate_field(fields, model, resource, view)
        {
          options: @options,
          display_labels: @display_labels,
          placeholder: @placeholder,
        }
      end
    end
  end
end
