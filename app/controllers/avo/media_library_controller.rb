module Avo
  class MediaLibraryController < ApplicationController
    include Pagy::Backend
    before_action :authorize_access!

    def index
      @attaching = false
    end

    def show
      @blob = ActiveStorage::Blob.find(params[:id])
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

    def attach
      @attaching = true

      render :index
    end

    private

    def attachment_params
      params.require(:attachment).permit(:filename, metadata: [:title, :alt, :description])
    end

    def authorize_access!
      raise_404 unless Avo::MediaLibrary.configuration.visible?
    end
  end
end
