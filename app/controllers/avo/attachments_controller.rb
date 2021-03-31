require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: :destroy
    before_action :set_resource, only: :destroy
    before_action :set_model, only: :destroy

    def show
    end

    def destroy
      blob = ActiveStorage::Blob.find(params[:signed_attachment_id])
      attachment = blob.attachments.find_by record_id: params[:id], record_type: @model.class.to_s

      if attachment.present?
        attachment.destroy

        redirect_to params[:referrer] || resource_path(@model), notice: t("avo.attachment_destroyed")
      else
        redirect_back fallback_location: resource_path(@model), notice: t("avo.failed_to_find_attachment")
      end
    end
  end
end
