# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListComponent < Avo::BaseComponent
      include Avo::ApplicationHelper
      include Pagy::Method

      NUMBER_DELIMITER = Avo::PaginatorComponent::NUMBER_DELIMITER

      def initialize(attaching: false, turbo_frame: nil)
        @attaching = attaching
        @pagy, @blobs = pagy(:offset, query, limit:)
        turbo_frame ||= params[:turbo_frame]
        @turbo_frame = turbo_frame.present? ? CGI.escapeHTML(turbo_frame.to_s) : :_top
      end

      def controller = Avo::Current.view_context.controller

      def query
        # ignore blobs who are just a variant to avoid "n+1" blob creation
        ActiveStorage::Blob.includes(:attachments)
          .where.not(id: ActiveStorage::Attachment.where(record_type: "ActiveStorage::VariantRecord").select(:blob_id))
          .order(created_at: :desc)
      end

      def limit = @attaching ? 12 : 24

      def formatted_count
        formatted_number(@pagy.count)
      end

      def formatted_series_nav
        @pagy.series_nav(anchor_string: %(data-turbo-frame="#{@turbo_frame}"))
          .gsub(/>(\d{4,})</) { |match| match.sub($1, formatted_number($1)) }
          .html_safe
      end

      private

      def formatted_number(number)
        helpers.number_with_delimiter(number, delimiter: NUMBER_DELIMITER)
      end
    end
  end
end
