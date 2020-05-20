require_relative 'field'

module Avocado
  module Fields
    class TextareaField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'textarea-field'
        }

        super(name, **args, &block)

        @rows = args[:rows].present? ? args[:rows].to_i : 5
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)

        fields[:rows] = @rows
        fields[:value] = @block.call model, resource, view, self if @block.present?

        fields
      end
    end
  end
end
