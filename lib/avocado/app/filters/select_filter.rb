require_relative '../filter'

module Avocado
  module Filters
    class SelectFilter < Avocado::Filter
      def initialize
        @component ||= 'select-filter'

        super
      end
    end
  end
end
