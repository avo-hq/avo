require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: [:destroy, :create]
    before_action :set_resource, only: [:destroy, :create]
    before_action :set_record, only: [:destroy, :create]

    def create
      blob = ActiveStorage::Blob.create_and_upload! io: params[:file].to_io, filename: params[:filename]
      association_name = BaseResource.valid_attachment_name(@record, params[:attachment_key])

      # If association name is present attach the blob to it
      if association_name
        @record.send(association_name).attach blob
      # If key is present use the blob from the key else raise error
      elsif params[:key].blank?
        raise ActionController::BadRequest.new("Could not find the attachment association for #{params[:attachment_key]} (check the `attachment_key` for this Trix field)")
      end

      render json: {
        url: main_app.url_for(blob),
        href: main_app.url_for(blob)
      }
    end

    def destroy
      if authorized_to :delete
        attachment = ActiveStorage::Attachment.find(params[:attachment_id])

        if attachment.present?
          ActiveRecord::Base.transaction do
            @destroyed = attachment
            attachment.destroy!
            @record.reload
            unless @record.save
              @destroyed = nil
              raise ActiveRecord::Rollback
            end
          end

          if @destroyed.present?
            flash[:notice] = t("avo.attachment_destroyed")
          else
            flash[:error] = @record.errors.full_messages.join(", ")
          end
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
      @resource.authorization.authorize_action("#{action}_#{params[:attachment_name]}?", record: @record, raise_exception: false)
    end
  end
end
