module Avo
  module Fields
    module Concerns
      # The `key` option of the `file` and `files` fields: where Active Storage puts an uploaded file in the
      # storage service (its blob key), instead of a random token. Takes a string or a block that sees the
      # `record`, the `resource`, the `field` and the uploaded `file`. Every blob needs a key of its own, so a key
      # that's already taken fails the save with the database's uniqueness error.
      module HasStorageKey
        extend ActiveSupport::Concern

        included do
          attr_reader :key
        end

        private

        # Returns the attachable to write for +file+. A file uploaded through the form, with a key to store it under,
        # becomes the hash Active Storage builds such a blob from. Anything else goes through unchanged: the signed id
        # of a direct upload or of a Media Library file names a blob that's already stored.
        def with_storage_key(file, record:)
          return file if @key.nil? || !file.is_a?(ActionDispatch::Http::UploadedFile)

          storage_key = Avo::ExecutionContext.new(target: @key, record:, resource: @resource, field: self, file:).handle
          return file if storage_key.blank?

          {io: file.open, filename: file.original_filename, content_type: file.content_type, key: storage_key.to_s}
        end
      end
    end
  end
end
