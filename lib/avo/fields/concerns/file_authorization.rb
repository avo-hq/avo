module Avo
  module Fields
    module Concerns
      module FileAuthorization
        extend ActiveSupport::Concern

        delegate :authorization, to: :@resource
        delegate :authorize_action, to: :authorization
        delegate :id, :model, to: :@field

        def can_upload_file?
          authorize_file_action(:upload)
        end

        def can_delete_file?
          authorize_file_action(:delete)
        end

        def can_download_file?
          authorize_file_action(:download)
        end

        private

        # First we check if user have authorization to act on attachments
        # If attachemnts level authorization is defined and user have authorization to act on attachments
        # We check field level authorization
        # If field level authorization is not defined or user do NOT have authorization to act on attachments
        # We return false
        def authorize_file_action(action)
          # If act on atachments (upload, download, delete) is defined
          # Check if user have authorization to act on attachments
          if authorization.has_method?("#{action}_attachments?", raise_exception: false)
            return false unless authorize_action("#{action}_attachments?", raise_exception: false)
          end

          # If act on attachemnts is not defined or user have authorization to act on attachments
          # Check  field level authorization
          authorize_action("#{action}_#{id}?", record: model, raise_exception: false)
        end
      end
    end
  end
end
