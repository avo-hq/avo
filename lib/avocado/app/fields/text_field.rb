require_relative './field'

module Avocado
  module Fields
    class TextField < Field
      def initialize(name, **args)
        super(name, args)

        @component = 'text-field'
        @sortable = true
      end
    end
  end
end
