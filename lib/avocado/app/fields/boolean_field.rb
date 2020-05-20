require_relative 'field'

module Avocado
  module Fields
    class BooleanField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'boolean-field',
        }

        super(name, **args, &block)

        @true_value = args[:true_value].present? ? args[:true_value] : true
        @false_value = args[:false_value].present? ? args[:false_value] : false
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)

        fields[:value] = if @block.present?
           @block.call model, resource, view, self
        else
          model[id] == @true_value
        end

        fields[:true_value] = @true_value
        fields[:false_value] = @false_value

        fields
      end
    end
  end
end
