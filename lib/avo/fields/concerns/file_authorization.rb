module Avo
  module Fields
    module Concerns
      module FileAuthorization
        extend ActiveSupport::Concern

        delegate :authorization, to: :@resource
        delegate :authorize_action, to: :authorization
        delegate :id, :model, to: :@field

        # Dynamically generate can_upload_file?, can_delete_file?, and can_download_file? methods
        [:upload, :delete, :download].each do |action|
          define_method "can_#{action}_file?" do
            # Check if the current user can perform the corresponding actions
            # upload_attachments?, delete_attachments?, and download_attachments?
            if authorize_action("#{action}_attachments?".to_sym, raise_exception: false)
              # Check if the current user can perform the action on the current file
              authorize_action("#{action}_#{id}?", record: model, raise_exception: false)
            end
          end
        end
      end
    end
  end
end
