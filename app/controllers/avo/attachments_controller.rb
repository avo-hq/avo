require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: [:destroy, :create]
    before_action :set_resource, only: [:destroy, :create]
    before_action :set_model, only: [:destroy, :create]

    def create
      blob = ActiveStorage::Blob.create_and_upload! io: params[:file], filename: params[:filename]
      association_name = BaseResource.valid_attachment_name(@model, params[:attachment_key])

      @model.send(association_name).attach blob

      render json: {
        url: main_app.url_for(blob),
        href: main_app.url_for(blob)
      }
    end

    def destroy
      attachment = ActiveStorage::Attachment.find(params[:attachment_id])
      path = resource_path(model: @model, resource: @resource)

      if attachment.present?
        attachment.destroy

        redirect_to params[:referrer] || path, notice: t("avo.attachment_destroyed")
      else
        redirect_back fallback_location: path, notice: t("avo.failed_to_find_attachment")
      end
    end
  end
end
