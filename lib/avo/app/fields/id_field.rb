module Avo
  module Fields
    class IdField < Field
      def initialize(name, **args, &block)
        default_value = 'id'

        if name.nil?
          @name = name = default_value
        elsif !name.is_a? String and !name.is_a? Symbol
          args_copy = name
          @name = name = default_value
          args = args_copy
        end

        @defaults = {
          id: name.to_sym,
          readonly: true,
          sortable: true,
          component: 'id-field'
        }

        hide_on [:edit, :create]

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
