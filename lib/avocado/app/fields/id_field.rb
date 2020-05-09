require_relative './field'

module Avocado
  module Fields
    class IdField < Field
      def initialize(*args)
        super

        @component = 'id-field'
        @can_be_updated = false
        @sortable = true
      end
    end
  end
end
