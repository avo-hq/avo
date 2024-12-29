module Avo
  class MediaController < ApplicationController
    def index
    end

    def show
      @attachment = ActiveStorage::Attachment.find(params[:id])
    end
  end
end
