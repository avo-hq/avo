# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListComponent < Avo::BaseComponent
      include Avo::ApplicationHelper
      include Pagy::Backend

      def initialize(parent:, attaching: false)
        @parent = parent
        @attaching = attaching
        @pagy, @attachments = pagy(query, limit: 12)
      end

      def controller = Avo::Current.view_context.controller

      def query
        ActiveStorage::Attachment.includes(:blob)
      end
    end
  end
end
