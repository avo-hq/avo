module Avo
  module Filters
    class BooleanFilter < BaseFilter
      self.template = "avo/base/boolean_filter"

      def selected_value(item, applied_filters)
        # See if there are any applied rules for this particular filter
        if applied_filters[self.class.to_s].present?
          # Symbolize the keys because they are returned from de-serialization (JSON and Base64)
          applied_filters[self.class.to_s].symbolize_keys.dig(item)
        else
          default_value(applied_filters).dig(item)
        end
      rescue
        false
      end
    end
  end
end
