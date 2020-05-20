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
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)

        fields[:value] = @block.call model, resource, view, self if @block.present?

        fields[:options] = @options

        fields
      end
    end
  end
end
