module Avo
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
        include Pagy::Backend

        class_attribute :pagination, default: {
          type: :normal
        }

        PAGINATION_METHOD = {
          normal: :pagy,
          countless: :pagy_countless,
        } unless defined? PAGINATION_METHOD
      end

      def pagination_type
        @pagination_type ||= pagination_hash[:type].to_sym
      end

      def apply_pagination(index_params:, query:)
        extra_pagy_params = {}

        # Reset open filters when a user navigates to a new page
        extra_pagy_params[:keep_filters_panel_open] = if params[:keep_filters_panel_open] == "1"
          "0"
        end

        send PAGINATION_METHOD[pagination_type],
          query,
          items: index_params[:per_page],
          link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"",
          params: extra_pagy_params,
          size: pagination_hash[:size] || [1, 2, 2, 1]
      end

      private

      def pagination_hash
        @pagination = Avo::ExecutionContext.new(
          target: pagination,
          resource: self,
          view: @view
        ).handle
      end
    end
  end
end
