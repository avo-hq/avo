module Avo
  module Filters
    class BaseFilter
      PARAM_KEY = :encoded_filters unless const_defined?(:PARAM_KEY)

      class_attribute :component, default: "boolean-filter"
      class_attribute :default, default: nil
      class_attribute :empty_message
      class_attribute :name, default: "Filter"
      class_attribute :template, default: "avo/base/select_filter"
      class_attribute :visible
      class_attribute :button_label

      attr_reader :arguments

      delegate :params, to: Avo::Current
      delegate :request, to: Avo::Current
      delegate :view_context, to: Avo::Current

      def current_user
        Avo::Current.user
      end

      class << self
        def decode_filters(filter_params)
          JSON.parse(Base64.decode64(filter_params))
        end

        def encode_filters(filter_params)
          Base64.encode64(filter_params.to_json)
        end

        def get_empty_message
          empty_message || I18n.t("avo.no_options_available")
        end
      end

      def initialize(arguments: {})
        @arguments = arguments
      end

      def apply_query(request, query, value)
        value.stringify_keys! if value.is_a? Hash

        apply(request, query, value)
      end

      def id
        name.underscore.tr("/", "_")
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
        # Return empty hash if no filters are present
        return {} if (filters_from_params = params[PARAM_KEY]).blank?

        # Return empty hash if the filters are not a string, decode_filters method expects a Base64 encoded string
        # Dynamic filters also use the "filters" param key, but they are not Base64 encoded, they are a hash
        return {} if !filters_from_params.is_a?(String)

        self.class.decode_filters filters_from_params
      end

      def visible_in_view(resource: nil, parent_resource: nil)
        return true if visible.blank?

        # Run the visible block if available
        Avo::ExecutionContext.new(
          target: visible,
          params: params,
          parent_resource: parent_resource,
          resource: resource,
          arguments: arguments
        ).handle
      end

      def name
        Avo::ExecutionContext.new(target: self.class.name).handle
      end

      def button_label
        Avo::ExecutionContext.new(target: self.class.button_label).handle
      end
    end
  end
end
