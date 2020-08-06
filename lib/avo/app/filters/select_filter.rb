require_relative '../filter'

module Avo
  module Filters
    class SelectFilter < Avo::Filter
      def initialize
        @component ||= 'select-filter'

        super
      end
    end
  end
end
