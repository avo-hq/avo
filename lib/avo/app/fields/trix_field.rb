require_relative 'field'

module Avo
  module Fields
    class TrixField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'trix-field',
        }

        super(name, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          always_show: @always_show
        }
      end
    end
  end
end
