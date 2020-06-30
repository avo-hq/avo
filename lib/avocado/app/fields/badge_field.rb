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
        @map = args[:map].present? and args[:map].is_a? Hash ? default_map.merge(args[:map]) : default_map
        # @styles = args[:styles].present? ? args[:styles] : {}
        # @add_styles = args[:add_styles].present? ? args[:add_styles] : {}
      end

      def hydrate_resource(model, resource, view)
        {
          map: @map,
          # styles: @styles,
          # add_styles: @add_styles,
        }
      end
    end
  end
end
