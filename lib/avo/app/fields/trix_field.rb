require_relative 'field'

module Avo
  module Fields
    class TrixField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'trix-field',
        }

        super(name, **args, &block)

        hide_on :index

        @rows = args[:rows].present? ? args[:rows].to_i : 5
      end

      def hydrate_field(fields, model, resource, view)
        {
          rows: @rows
        }
      end
    end
  end
end
