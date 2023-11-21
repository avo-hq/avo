module Avo
  module Fields
    module Concerns
      module FileAuthorization
        extend ActiveSupport::Concern

        delegate :authorization, to: :@resource
        delegate :authorize_action, to: :authorization
        delegate :id, :record, to: :@field

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

        def authorize_file_action(action)
          authorize_action("#{action}_#{id}?", record: record, raise_exception: false)
        end
      end
    end
  end
end
