module Avo
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
        include Avo::PagyCompat.backend

        class_attribute :pagination, default: {}

        unless defined? PAGINATION_METHOD
          PAGINATION_METHOD = {
            default: :pagy,
            countless: :pagy_countless,
            array: :pagy_array,
          }
        end

        unless defined? PAGINATION_DEFAULTS
          PAGINATION_DEFAULTS = {
            type: :default,
            size: ::Pagy::VERSION >= ::Gem::Version.new("9.0") ? 9 : [1, 2, 2, 1],
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

        # Perform pagination and fallback to first page when the page is out of range
        begin
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        rescue Avo::PagyCompat.page_out_of_range_error
          index_params[:page] = 1
          perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        end
      end

      private

      def perform_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        if Avo::PagyCompat.pagy_43?
          return perform_pagy_43_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        end

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

      # Pagy 43 paginates arrays with :offset, and has no trim extra: it always links page 1 with page=1.
      def perform_pagy_43_pagination(index_params:, query:, data_turbo_frame:, extra_pagy_params:, **args)
        pagy pagination_type.countless? ? :countless : :offset,
          query,
          **args.except(:trim_extra),
          page: index_params[:page],
          limit: index_params[:per_page],
          anchor_string: data_turbo_frame,
          querify: ->(query_params) { query_params.merge!(extra_pagy_params.stringify_keys) },
          slots: Avo::PagyCompat.slots(pagination_hash[:size]),
          raise_range_error: true
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
