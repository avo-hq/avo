module Avo
  module MediaLibrary
    class ItemsController < Avo::ApplicationController
      include Pagy::Backend

      def index
      end

      def show
        @attachment = ActiveStorage::Attachment.find(params[:id])
      end

      def create
        resource = Avo.resource_manager.get_resource_by_name(params[:resource_name])
        @parent = resource.find_record(params[:record_id])
      end

      def destroy
        @attachment = ActiveStorage::Attachment.find(params[:id])
        @attachment.destroy!
        redirect_to avo.media_library_path
      end

      def update
        @attachment = ActiveStorage::Attachment.find(params[:id])
        @attachment.update!(attachment_params)
        redirect_to avo.media_library_path
      end

      private

      def attachment_params
        params.require(:attachment).permit(:filename, metadata: [:title, :alt, :description])
      end
    end
  end
end
