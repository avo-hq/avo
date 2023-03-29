require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: [:destroy, :create]
    before_action :set_resource, only: [:destroy, :create]
    before_action :set_model, only: [:destroy, :create]

    def create
      blob = ActiveStorage::Blob.create_and_upload! io: params[:file], filename: params[:filename]
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
      raise Avo::NotAuthorizedError.new unless authorized_to :delete

      attachment = ActiveStorage::Attachment.find(params[:attachment_id])
      path = resource_path(model: @model, resource: @resource)

      if attachment.present?
        attachment.destroy

        redirect_to params[:referrer] || path, notice: t("avo.attachment_destroyed")
      else
        redirect_back fallback_location: path, notice: t("avo.failed_to_find_attachment")
      end
    end

    private

    def authorized_to(action)
      if @resource.authorization.authorize_action("#{action}_attachments?".to_sym, raise_exception: false)
        @resource.authorization.authorize_action("#{action}_#{params[:attachment_name]}?", record: @model, raise_exception: false)
      end
    end
  end
end
