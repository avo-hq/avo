module Avo
  class MediaLibraryController < Avo::ApplicationController
    include Pagy::Method

    before_action :authorize_access!
    before_action -> { @container_size = "lg" }, only: [:edit]

    def index
      @attaching = false
      add_breadcrumb title: "Media Library", initials: "ML"
    end

    def show
      redirect_to avo.edit_media_library_path(params[:id])
    end

    def edit
      @blob = ActiveStorage::Blob.find(params[:id])

      add_breadcrumb title: "Media Library", path: avo.media_library_index_path, initials: "ML"
      add_breadcrumb title: @blob.filename.to_s, path: nil, initials: extract_initials(@blob.filename.to_s)
    end

    # The next page of a csv preview table, appended by the "load more" button.
    def rows
      @blob = ActiveStorage::Blob.find(params[:id])
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
      refusal = nil

      # One refusal keeps the file on every record, so a delete never half-happens.
      ActiveRecord::Base.transaction do
        @blob.attachments.each do |attachment|
          refusal = detach(attachment)
          raise ActiveRecord::Rollback if refusal
        end

        @blob.destroy!
      end

      if refusal
        flash[:error] = refusal
        return redirect_to avo.edit_media_library_path(@blob), status: :see_other
      end

      # Only once the rows are gone for good: a rolled-back delete must still find its file.
      @blob.delete

      # A `fetch` keeps DELETE across a 302, so send the browser on with a GET.
      redirect_to avo.media_library_index_path, status: :see_other
    end

    def update
      @blob = ActiveStorage::Blob.find(params[:id])

      # A blank filename makes the blob unroutable (Active Storage URLs need a
      # :filename segment) — refuse it rather than mangling the blob. Omitted
      # filename (metadata-only PATCH) is fine; leave the existing name alone.
      if blob_params.key?(:filename) && blob_params[:filename].blank?
        flash[:error] = "Filename can't be blank."
        return redirect_to avo.edit_media_library_path(@blob)
      end

      attributes = {
        # Merge, don't replace: keep system metadata (width/height/analyzed/…).
        metadata: @blob.metadata.merge(blob_params[:metadata]&.to_h || {})
      }
      attributes[:filename] = blob_params[:filename] if blob_params.key?(:filename)

      @blob.update!(attributes)

      redirect_to avo.edit_media_library_path(@blob)
    end

    def attach
      @attaching = true

      render :index
    end

    private

    # Removes the file from one record, under the same policy method and validations as the trash icon on that
    # record's file field. Returns why it can't, or nil.
    def detach(attachment)
      record = attachment.record
      resource_class = record && Avo.resource_manager.get_resource_by_model_class(record.class)

      # No resource means no policy or form to apply: the record is gone, or Avo doesn't manage it (a rich text
      # body, which would re-attach its embeds on save). A gone record's row skips the callbacks that read it.
      if resource_class.nil?
        record.nil? ? attachment.delete : attachment.destroy!
        return
      end

      label = helpers.media_library_record_label(attachment)
      authorized = resource_class.new(record: record).authorization
        .authorize_action("delete_#{attachment.name}?", record: record, raise_exception: false)
      return "You aren't allowed to remove this file from #{label}." unless authorized

      attachment.destroy!
      return if record.reload.save

      "This file can't be removed from #{label}: #{record.errors.full_messages.to_sentence}"
    end

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
