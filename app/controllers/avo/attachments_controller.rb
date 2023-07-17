require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: [:destroy, :create]
    before_action :set_resource, only: [:destroy, :create]
    before_action :set_model, only: [:destroy, :create]

    def create
      blob = ActiveStorage::Blob.create_and_upload! io: params[:file].to_io, filename: params[:filename]
      association_name = BaseResource.valid_attachment_name(@model, params[:attachment_key])

      if association_name.blank?
        raise ActionController::BadRequest.new("Could not find the attachment association for #{params[:attachment_key]} (check the `attachment_key` for this Trix field)")
      end

      @model.send(association_name).attach blob

      render json: {
        url: main_app.url_for(blob),
        href: main_app.url_for(blob)
      }
    end

    def destroy
      if authorized_to :delete
        attachment = ActiveStorage::Attachment.find(params[:attachment_id])

        flash[:notice] = if attachment.present?
          @destroyed = attachment.destroy

          t("avo.attachment_destroyed")
        else
          t("avo.failed_to_find_attachment")
        end
      else
        flash[:notice] = t("avo.not_authorized")
      end

      respond_to do |format|
        format.turbo_stream do
          render "destroy"
        end
      end
    end

    private

    def authorized_to(action)
      @resource.authorization.authorize_action("#{action}_#{params[:attachment_name]}?", record: @model, raise_exception: false)
    end
  end
end
