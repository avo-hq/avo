require_relative './field'

module Avocado
  module Fields
    class IdField < Field
      def initialize(name = 'ID', **args)
        super(name, args)

        @name = name
        @component = 'id-field'
        @updatable = false
        @sortable = true
      end
    end
  end
end
