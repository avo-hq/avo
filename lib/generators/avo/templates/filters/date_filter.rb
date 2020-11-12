module Avo
  module Filters
    class <%= class_name.camelize %> < DateFilter
      def name
        '<%= name.underscore.humanize %>'
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
