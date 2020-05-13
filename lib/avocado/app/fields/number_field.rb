require_relative './field'

module Avocado
  module Fields
    class NumberField < Field
      def initialize(name = 'Number', **args)
        super(name, args)

        @name = name
        @component = 'number-field'
        @sortable = true
      end
    end
  end
end
