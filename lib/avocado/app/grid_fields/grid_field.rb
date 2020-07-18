module Avocado
  module GridFields
    class GridField
      attr_accessor :id

      def initialize(id, **args, &block)
        @id = id
      end
    end
  end
end
