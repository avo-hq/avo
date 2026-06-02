require_dependency "avo/application_controller"

module Avo
  class AttachmentsController < ApplicationController
    before_action :set_resource_name, only: [:destroy, :create]
    before_action :set_resource, only: [:destroy, :create]
    before_action :set_record, only: [:destroy, :create]

    def create
      association_name = BaseResource.valid_attachment_name(@record, params[:attachment_key])

      if association_name
        return render_upload_unauthorized unless authorized_to_upload(association_name)

        blob = ActiveStorage::Blob.create_and_upload! io: params[:file].to_io, filename: params[:filename]
        @record.send(association_name).attach blob
      elsif params[:key].present?
        return render_upload_unauthorized unless authorized_to_trix_upload?

        blob = ActiveStorage::Blob.create_and_upload! io: params[:file].to_io, filename: params[:filename]
      else
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

    def authorized_to_upload(attachment_name)
      @resource.authorization.authorize_action("upload_#{attachment_name}?", record: @record, raise_exception: false)
    end

    def authorized_to_trix_upload?
      @resource.authorization.authorize_action("update?", record: @record, raise_exception: false)
    end

    def render_upload_unauthorized
      render json: {error: "Not authorized"}, status: :forbidden
    end
  end
end
