require_relative '../filter'

module Avo
  module Filters
    class BooleanFilter < Avo::Filter
      def initialize
        @component ||= 'boolean-filter'

        super
      end
    end
  end
end
