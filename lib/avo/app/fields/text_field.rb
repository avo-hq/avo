module Avo
  module Fields
    class TextField < Field
      def initialize(name, **args, &block)
        @defaults = {
          sortable: true,
          component: 'text-field',
          computable: true,
        }.merge(@defaults || {})

        super(name, **args, &block)
      end
    end
  end
end
