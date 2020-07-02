module Avocado
  module Filters
    class AvailabilityFilter < SelectFilter
      def name
        'Availability filter'
      end

      def apply(request, query, value)
        case value
        when 'available'
          return query.where(availability: true)
        when 'unavailable'
          return query.where(availability: false)
        else
          query
        end
      end

      def options
        {
          'available': 'Available',
          'unavailable': 'Unavailable',
        }
      end
    end
  end
end
