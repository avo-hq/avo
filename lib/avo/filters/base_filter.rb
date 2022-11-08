module Avo
  module Filters
    class BaseFilter
      PARAM_KEY = :filters unless const_defined?(:PARAM_KEY)

      class_attribute :component, default: "boolean-filter"
      class_attribute :default, default: nil
      class_attribute :empty_message
      class_attribute :name, default: "Filter"
      class_attribute :template, default: "avo/base/select_filter"
      class_attribute :visible

      delegate :params, to: Avo::App

      class << self
        def decode_filters(filter_params)
          JSON.parse(Base64.decode64(filter_params))
        rescue
          {}
        end

        def get_empty_message
          empty_message || I18n.t("avo.no_options_available")
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

      def visible_in_view(resource: nil, parent_model: nil, parent_resource: nil)
        return true if visible.blank?

        # Run the visible block if available
        Avo::Hosts::VisibilityHost.new(
          block: visible,
          params: params,
          parent_model: parent_model,
          parent_resource: parent_resource,
          resource: resource
        ).handle

      end
    end
  end
end
