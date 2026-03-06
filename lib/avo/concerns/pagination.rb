module Avo
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
        include Avo::Concerns::PagyCompatibility

        class_attribute :pagination, default: {}

        unless defined? PAGINATION_DEFAULTS
          PAGINATION_DEFAULTS = {
            type: :default,
            size: if ::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("43.0")
                    4
                  else
                    ((::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("9.0")) ? 9 : [1, 2, 2, 1])
                  end,
          }
        end
      end

      def pagination_type
        @pagination_type ||= ActiveSupport::StringInquirer.new(pagination_hash[:type].to_s)
      end

      def apply_pagination(index_params:, query:, **args)
        extra_pagy_params = {}

        # Reset open filters when a user navigates to a new page
        if params[:keep_filters_panel_open] == "1"
          extra_pagy_params[:keep_filters_panel_open] = "0"
        end

        data_turbo_frame = "data-turbo-frame=\"#{CGI.escapeHTML(params[:turbo_frame]) if params[:turbo_frame]}\""

        # Perform pagination and fallback to first page on Pagy::OverflowError
        begin
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        rescue => error
          raise error unless pagy_overflow?(error)

          index_params[:page] = 1
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        end
      end

      private

      def perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        if pagy_v43_or_newer?
          pagy(
            pagy_kind_for_v43,
            query,
            **args,
            page: index_params[:page],
            limit: index_params[:per_page],
            anchor_string: data_turbo_frame,
            querify: pagy_querify(extra_pagy_params),
            slots: pagination_slots,
            raise_range_error: true
          )
        else
          send PAGINATION_METHOD[pagination_type.to_sym],
            query,
            **args,
            page: index_params[:page],
            items: index_params[:per_page], # Add per page in pagy < 9
            limit: index_params[:per_page], # Add per page in pagy >= 9
            link_extra: data_turbo_frame, # Add extra arguments in pagy 7.
            anchor_string: data_turbo_frame, # Add extra arguments in pagy 8.
            params: extra_pagy_params,
            size: pagination_hash[:size]
        end
      end

      def pagy_kind_for_v43
        case pagination_type.to_sym
        when :countless
          :countless
        else
          :offset
        end
      end

      def pagy_querify(extra_pagy_params)
        return nil if extra_pagy_params.blank?

        lambda do |params_hash|
          params_hash.merge!(extra_pagy_params.transform_keys(&:to_s))
        end
      end

      def pagy_overflow_errors
        errors = []
        errors << ::Pagy::OverflowError if defined?(::Pagy::OverflowError)
        errors << ::Pagy::RangeError if defined?(::Pagy::RangeError)
        errors
      end

      def pagy_overflow?(error)
        pagy_overflow_errors.any? { |klass| error.is_a?(klass) }
      end

      def pagination_slots
        value = pagination_hash[:size]
        value.is_a?(Array) ? value.sum : value
      end

      unless defined? PAGINATION_METHOD
        PAGINATION_METHOD = {
          default: :pagy,
          countless: :pagy_countless,
          array: :pagy_array,
        }
      end

      def pagination_hash
        @pagination ||= PAGINATION_DEFAULTS.merge(Avo.configuration.pagination).merge Avo::ExecutionContext.new(
          target: pagination,
          resource: self,
          view: @view
        ).handle
      end
    end
  end
end
