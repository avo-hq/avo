module Avo
  module Fields
    class IdField < Field
      def initialize(name, **args, &block)
        @defaults = {
          id: :id,
          readonly: true,
          sortable: true,
          component: 'id-field'
        }

        hide_on [:edit, :create]

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
