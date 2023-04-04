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
        # If attachemnts level authorization is defined and user do NOT have authorization to act on attachments
        # We return false

        # If attachemnts level authorization is defined and user have authorization to act on attachments
        # We check if field level authorization is defined

        # If field level authorization is NOT defined we return true
        # If field level authorization is defined we return field level authorization
        def authorize_file_action(action)
          # If act on atachments (upload, download, delete) is defined
          # Check if user have authorization to act on attachments
          if authorization.has_method?("#{action}_attachments?", raise_exception: false)
            return false unless authorize_action("#{action}_attachments?", raise_exception: false)

            # If user have authorization to act on attachments
            # And field level authorization is not defined
            # We return true
            if !authorization.has_method?("#{action}_#{id}?", raise_exception: false)
              return true
            end
          end

          # If field level authorization is defined
          # And act on attachemnts is not defined or user have authorization to act on attachments
          # Return field level authorization
          authorize_action("#{action}_#{id}?", record: model, raise_exception: false)
        end
      end
    end
  end
end
