module Avo
  module Filters
    class <%= class_name.camelize %> < SelectFilter
      def configure
        @name = '<%= name.underscore.humanize %>'
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
