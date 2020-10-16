module Avo
  module Fields
    class TextField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'text-field',
          computable: true,
        }.merge(@defaults || {})

        super(name, **args, &block)

        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          link_to_resource: @link_to_resource,
        }
      end
    end
  end
end
