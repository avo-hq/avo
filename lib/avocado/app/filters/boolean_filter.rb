require_relative '../filter'

module Avocado
  module Filters
    class BooleanFilter < Avocado::Filter
      def initialize
        @component ||= 'boolean-filter'

        super
      end
    end
  end
end
