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
      raise_404 if Avo::MediaLibrary.configuration.disabled?

      # `visible` is the per-user gate for the whole feature, not just the
      # sidebar item. It reads like access control -- a block returning false
      # for a user is plainly meant to keep that user out -- so it has to be
      # enforced here, or every Media Library route stays reachable by URL to
      # anyone who can sign in to Avo.
      raise_404 unless Avo::MediaLibrary.configuration.visible?
    end
  end
end
