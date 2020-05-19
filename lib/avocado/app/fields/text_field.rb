require_relative 'field'

module Avocado
  module Fields
    class TextField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'text-field'
        }.merge(@defaults || {})

        super(name, **args, &block)
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:value] = @block.call model, self if @block.present?

        fields
      end
    end
  end
end
