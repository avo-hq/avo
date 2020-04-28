require_relative './field'

module Avocado
  module Fields
    class TextField < Field
      def initialize(*args)
        super

        @component = 'text-field'
      end
    end
  end
end
