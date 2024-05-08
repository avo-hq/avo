module Avo
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
        include Pagy::Backend

        class_attribute :pagination, default: {}

        unless defined? PAGINATION_METHOD
          PAGINATION_METHOD = {
            default: :pagy,
            countless: :pagy_countless,
          }
        end

        unless defined? PAGINATION_DEFAULTS
          PAGINATION_DEFAULTS = {
            type: :default,
            size: [1, 2, 2, 1],
          }
        end
      end

      def pagination_type
        @pagination_type ||= ActiveSupport::StringInquirer.new(pagination_hash[:type].to_s)
      end

      def apply_pagination(index_params:, query:)
        extra_pagy_params = {}

        # Reset open filters when a user navigates to a new page
        if params[:keep_filters_panel_open] == "1"
          extra_pagy_params[:keep_filters_panel_open] = "0"
        end

        send PAGINATION_METHOD[pagination_type.to_sym],
          query,
          items: index_params[:per_page],
          link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"", # Add extra arguments in pagy 8.
          anchor_string: "data-turbo-frame=\"#{params[:turbo_frame]}\"", # Add extra arguments in pagy 7.
          params: extra_pagy_params,
          size: pagination_hash[:size]
      end

      private

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
