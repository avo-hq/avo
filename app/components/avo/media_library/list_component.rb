# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListComponent < Avo::BaseComponent
      include Pagy::Backend
      def initialize
        @pagy, @attachments = pagy(ActiveStorage::Attachment.includes(:blob).all, limit: 12)
      end

      def controller = Avo::Current.view_context.controller
    end
  end
end
