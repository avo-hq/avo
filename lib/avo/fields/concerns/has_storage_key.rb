module Avo
  module Fields
    module Concerns
      # The `key` option of the `file` and `files` fields: the blob key Active Storage stores an uploaded file under,
      # instead of a random token. A string, or a block that sees the `record`, `resource`, `field` and `file`.
      module HasStorageKey
        extend ActiveSupport::Concern

        included do
          attr_reader :key
        end

        private

        # Direct uploads and Media Library files arrive as signed ids of blobs that are already stored, so they keep
        # their key. Only a file uploaded through the form becomes the attachable hash that carries one.
        def with_storage_key(file, record:)
          return file if @key.nil? || !file.is_a?(ActionDispatch::Http::UploadedFile)

          storage_key = Avo::ExecutionContext.new(target: @key, record:, resource: @resource, field: self, file:).handle.to_s
          return file if storage_key.blank?

          # Keys are unique and a replaced file's blob is purged after the new one is saved, so a re-upload of the same
          # key would fail the save with the database's error. save_record stops on this field error instead.
          taken = ActiveStorage::Blob.exists?(key: storage_key) || !storage_keys.add?(storage_key)
          record.errors.add(id, :taken) if taken

          {io: file.open, filename: file.original_filename, content_type: file.content_type, key: storage_key}
        end

        # Keys given out during this fill, so two files of one upload can't share a key either
        def storage_keys
          @storage_keys ||= Set.new
        end
      end
    end
  end
end
