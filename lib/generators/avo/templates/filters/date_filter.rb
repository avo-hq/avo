module Avo
  module Filters
    class <%= class_name.camelize %> < DateFilter
      def name
        '<%= name.underscore.humanize %>'
      end

      def apply(request, query, value)
        query
      end

      def filter_configuration
        defaults = {
          range: false,
          first_day_of_week: 0,
          picker_format: "Y-m-d",
          placeholder: "",
        }

        return configuration.reverse_merge!(defaults) if defined? configuration

        defaults
      end
    end
  end
end
