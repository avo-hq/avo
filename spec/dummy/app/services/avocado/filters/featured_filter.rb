module Avocado
  module Filters
    class FeaturedFilter < BooleanFilter
      def name
        'Featured status'
      end

      def apply(request, query, values)
        return query if values[:featured] && values[:unfeatured]

        if values[:featured]
          query = query.where(featured: true)
        elsif values[:unfeatured]
          query = query.where(featured: false)
        end

        query
      end

      def options
        {
          'featured': 'Featured',
          'unfeatured': 'Unfeatured',
        }
      end
    end
  end
end
