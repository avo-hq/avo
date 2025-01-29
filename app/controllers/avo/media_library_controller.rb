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

    def destroy
      @blob = ActiveStorage::Blob.find(params[:id])
      @blob.destroy!

      redirect_to avo.media_library_index_path
    end

    def update
      @blob = ActiveStorage::Blob.find(params[:id])
      @blob.update!(blob_params)
    end

    def attach
      @attaching = true

      render :index
    end

    private

    def blob_params
      params.require(:blob).permit(:filename, metadata: [:title, :alt, :description])
    end

    def authorize_access!
      raise_404 unless Avo::MediaLibrary.configuration.visible?
    end
  end
end
