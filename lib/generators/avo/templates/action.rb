module Avo
  module Actions
    class <%= class_name.camelize %> < Action
      def name
        '<%= name.underscore.humanize %>'
      end

      def handle(request, models, fields)
        query
      end

      def fields
        {}
      end
    end
  end
end
