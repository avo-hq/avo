module Avo
  class MediaLibraryController < ApplicationController
    include Pagy::Backend
    before_action :authorize_access!
    before_action -> { @container_size = "large" }, on: [:show]

    def index
      @attaching = false
      add_breadcrumb title: "Media Library", initials: "ML"
    end

    def show
      @blob = ActiveStorage::Blob.find(params[:id])

      add_breadcrumb title: "Media Library", path: avo.media_library_index_path, initials: "ML"
      add_breadcrumb title: @blob.filename.to_s, path: nil, initials: extract_initials(@blob.filename.to_s)
    end

    def extract_initials(filename)
      # Remove file extension
      name_without_ext = File.basename(filename, File.extname(filename))

      # Split by spaces and take first 2 words
      words = name_without_ext.split(" ").first(2)

      # Extract first character of each word and join
      words.map { |word| word[0] }.join("").upcase
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
    end
  end
end
