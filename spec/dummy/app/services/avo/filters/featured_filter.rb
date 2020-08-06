module Avo
  module Filters
    class FeaturedFilter < BooleanFilter
      def name
        'Featured status'
      end

      def apply(request, query, values)
        return query if values[:is_featured] && values[:is_unfeatured]

        if values[:is_featured]
          query = query.where(is_featured: true)
        elsif values[:is_unfeatured]
          query = query.where(is_featured: false)
        end

        query
      end

      def options
        {
          'is_featured': 'Featured',
          'is_unfeatured': 'Unfeatured',
        }
      end
    end
  end
end
