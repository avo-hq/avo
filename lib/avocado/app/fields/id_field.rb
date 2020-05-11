require_relative './field'

module Avocado
  module Fields
    class IdField < Field
      def initialize(name = 'ID', **args)
        super(name, args)

        @name = name
        @component = 'id-field'
        @can_be_updated = false
        @sortable = true
      end
    end
  end
end
