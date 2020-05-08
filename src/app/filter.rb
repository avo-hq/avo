module Avocado
  module Filters
    class Filter
      attr_reader :name
      attr_reader :component

      def initialize
        @name ||= 'Filter'
        @component ||= 'select-filter'
      end

      def render_response
        {
          name: name,
          options: options,
          component: component,
          filter_class: self.class.to_s,
        }
      end

      def apply_query(request, query, value)
        self.apply(request, query, value)
      end
    end
  end
end