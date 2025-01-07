# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListComponent < Avo::BaseComponent
      include Avo::ApplicationHelper
      include Pagy::Backend

      # prop :turbo_frame do |frame|
      #   frame ||= params[:turbo_frame]
      #   puts ["frame->", frame].inspect
      #   frame.present? ? CGI.escapeHTML(frame) : :_top
      # end

      def initialize(parent:, attaching: false, turbo_frame: nil)
        @parent = parent
        @attaching = attaching
        # @turbo_frame = turbo_frame
        @pagy, @attachments = pagy(query, limit: 12)

        puts ["0 turbo_frame->", turbo_frame, params[:turbo_frame]].inspect
        turbo_frame ||= params[:turbo_frame]
        puts ["turbo_frame->", turbo_frame].inspect
        @turbo_frame = turbo_frame.present? ? CGI.escapeHTML(turbo_frame.to_s) : :_top
      end

      def controller = Avo::Current.view_context.controller

      def query
        ActiveStorage::Attachment.includes(:blob)
      end
    end
  end
end
