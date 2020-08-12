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

        @as_link_to_resource = args[:as_link_to_resource].present? ? args[:as_link_to_resource] : false
      end

      def hydrate_field(fields, model, resource, view)
        {
          as_link_to_resource: @as_link_to_resource,
        }
      end
    end
  end
end
