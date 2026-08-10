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
      if attachment_name.blank?
        flash[:error] = t("avo.failed_to_find_attachment")
      elsif !authorized_to(:delete)
        flash[:notice] = t("avo.not_authorized")
      else
        attachment = attachment_to_destroy

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
          flash[:error] = t("avo.failed_to_find_attachment")
        end
      end

      respond_to do |format|
        format.turbo_stream do
          render "destroy"
        end
      end
    end

    private

    # The attachment association named in the URL, validated against the record
    # it is being requested on. Blank when the name is not an attachment on this
    # record, which keeps `params[:attachment_name]` out of the policy method
    # name below.
    def attachment_name
      return @attachment_name if defined?(@attachment_name)

      @attachment_name = BaseResource.valid_attachment_name(@record, params[:attachment_name])
    end

    # Resolve the attachment through the record and association that were
    # authorized. `params[:attachment_id]` is attacker-controlled and
    # independent of `params[:id]`, so an unscoped lookup here would let a user
    # authorized on one record destroy any attachment in the application.
    def attachment_to_destroy
      ActiveStorage::Attachment.find_by(
        id: params[:attachment_id],
        record: @record,
        name: attachment_name
      )
    end

    def authorized_to(action)
      @resource.authorization.authorize_action("#{action}_#{attachment_name}?", record: @record, raise_exception: false)
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
