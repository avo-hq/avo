require_relative 'field'

module Avocado
  module Fields
    class TextField < Field
      include IsReadonly

      @defaults = {
        sortable: true,
        sortable: true,
        component: 'teext-field'
      }

      def fetch_for_resource(model, view = :index)
        fields = super(model, view)

        fields[:value] = @block.call model, self if @block.present?

        fields
      end
    end
  end
end
