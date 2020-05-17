require_relative './field'

module Avocado
  module Fields
    class TextField < Field
      include IsReadonly

      def initialize(name, **args, &block)
        super(name, **args, &block)

        @component = 'text-field'
        @sortable = true
      end

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:value] = @block.call model, self if @block.present?

        fields
      end
    end
  end
end
