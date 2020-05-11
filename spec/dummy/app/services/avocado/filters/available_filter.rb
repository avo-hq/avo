module Avocado
  module Filters
    class AvailableFilter < Filter
      def name
        'Availability filter'
      end

      def apply(request, query, value)
        if value.present?
          return query.where(availability: value)
        end

        query
      end

      def options
        {
          true: 'Available',
          false: 'Unavailable',
        }
      end
    end
  end
end
