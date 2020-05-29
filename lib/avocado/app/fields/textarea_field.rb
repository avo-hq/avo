require_relative 'text_field'

module Avocado
  module Fields
    class TextareaField < TextField
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'textarea-field',
          computable: true,
        }

        super(name, **args, &block)

        hide_on :index

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
