module Avo
  module Filters
    class BaseFilter
      PARAM_KEY = :filters unless const_defined?(:PARAM_KEY)

      class_attribute :name, default: "Filter"
      class_attribute :component, default: "boolean-filter"
      class_attribute :default, default: nil
      class_attribute :template, default: "avo/base/select_filter"
      class_attribute :empty_message, default: I18n.t("avo.no_options_available")

      delegate :params, to: Avo::App

      class << self
        def decode_filters(filter_params)
          JSON.parse(Base64.decode64(filter_params))
        rescue
          {}
        end
      end

      def apply_query(request, query, value)
        value.stringify_keys! if value.is_a? Hash

        apply(request, query, value)
      end

      def id
        self.class.name.underscore.tr("/", "_")
      end

      # Get the applied value this filter.
      # If it's not present return the default value.
      def applied_or_default_value(applied_filters)
        # Get the values for this particular filter
        applied_value = applied_filters[self.class.to_s]

        # Return that value if present
        return applied_value unless applied_value.nil?

        # Return that default
        default
      rescue
        default
      end

      # Fetch the applied filters from the params
      def applied_filters
        self.class.decode_filters params[PARAM_KEY]
      end
    end
  end
end
