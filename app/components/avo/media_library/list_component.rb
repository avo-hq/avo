# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListComponent < Avo::BaseComponent
      include Avo::ApplicationHelper
      include Pagy::Backend

      def initialize(attaching: false, turbo_frame: nil)
        @attaching = attaching
        @pagy, @blobs = pagy(query, limit:)
        turbo_frame ||= params[:turbo_frame]
        @turbo_frame = turbo_frame.present? ? CGI.escapeHTML(turbo_frame.to_s) : :_top
      end

      def controller = Avo::Current.view_context.controller

      def query
        ActiveStorage::Blob.includes(:attachments)
          # ignore blobs who are just a variant to avoid "n+1" blob creation
          .where.not(id: ActiveStorage::Attachment.where(record_type: "ActiveStorage::VariantRecord").select(:blob_id))
          .order(created_at: :desc)
      end

      def limit = @attaching ? 12 : 24
    end
  end
end
