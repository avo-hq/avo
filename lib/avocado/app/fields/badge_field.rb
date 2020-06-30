require_relative 'field'

module Avocado
  module Fields
    class BadgeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'badge-field',
        }

        super(name, **args, &block)

        default_map = { info: 'info', success: 'success', danger: 'danger', warning: 'warning' }
        @map = args[:map].present? ? default_map.merge(args[:map]) : default_map
      end

      def hydrate_resource(model, resource, view)
        {
          map: @map,
        }
      end
    end
  end
end
