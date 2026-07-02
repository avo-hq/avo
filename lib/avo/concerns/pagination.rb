module Avo
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
        include Pagy::Method

        class_attribute :pagination, default: {}

        unless defined? PAGINATION_DEFAULTS
          PAGINATION_DEFAULTS = {
            type: :default,
            slots: 9,
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

        # Perform pagination and fallback to first page on Pagy::RangeError.
        begin
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        rescue Pagy::RangeError
          index_params[:page] = 1
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        end
      end

      private

      def perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        pagy(
          pagy_kind,
          query,
          **args,
          page: index_params[:page],
          limit: index_params[:per_page],
          anchor_string: data_turbo_frame,
          querify: pagy_querify(extra_pagy_params),
          slots: pagination_hash[:slots],
          raise_range_error: true
        )
      end

      def pagy_kind
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
