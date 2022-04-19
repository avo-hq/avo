module Avo
  module Filters
    class BooleanFilter < BaseFilter
      self.template = "avo/base/boolean_filter"

      def selected_value(item, applied_filters)
        # See if there are any applied rules for this particular filter
        if applied_filters[self.class.to_s].present?
          # Symbolize the keys because they are returned from de-serialization (JSON and Base64)
          applied_filters[self.class.to_s].stringify_keys.dig(item.to_s)
        else
          applied_or_default_value(applied_filters).stringify_keys.dig(item.to_s)
        end
      rescue
        false
      end
    end
  end
end
