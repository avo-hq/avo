require_relative 'field'

module Avocado
  module Fields
    class TextareaField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'textarea-field',
          computable: true,
        }

        super(name, **args, &block)

        @rows = args[:rows].present? ? args[:rows].to_i : 5
      end

      def hydrate_resource(model, resource, view)
        {
          rows: @rows
        }
      end
    end
  end
end
