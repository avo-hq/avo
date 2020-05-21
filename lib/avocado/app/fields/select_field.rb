require_relative 'field'

module Avocado
  module Fields
    class SelectField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'select-field',
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : null
        @display_with_value = args[:display_with_value].present? ? args[:display_with_value] : false
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)

        fields[:value] = if @block.present?
          @block.call model, resource, view, self
        else
          model[id]
        end

        fields[:options] = @options
        fields[:display_with_value] = @display_with_value

        fields
      end
    end
  end
end
