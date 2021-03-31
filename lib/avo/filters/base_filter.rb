module Avo
  module Filters
    class BaseFilter
      class_attribute :name, default: "Filter"
      class_attribute :component, default: "boolean-filter"
      class_attribute :default, default: ""
      class_attribute :template, default: "avo/base/select_filter"

      def apply_query(request, query, value)
        value.symbolize_keys! if value.is_a? Hash

        apply(request, query, value)
      end

      def id
        self.class.name.underscore.tr("/", "_")
      end
    end
  end
end
