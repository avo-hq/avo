module Avocado
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
      end
    end
  end
end
