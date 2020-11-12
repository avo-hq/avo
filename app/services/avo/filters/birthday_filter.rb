module Avo
  module Filters
    class BirthdayFilter < DateFilter
      def name
        'Birthday filter'
      end

      def apply(request, query, value)
        query
      end

      def options
        {}
      end
    end
  end
end
