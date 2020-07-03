require_relative 'field'

module Avocado
  module Fields
    class FilesField < Field
      include Rails.application.routes.url_helpers
      attr_accessor :is_image

      def initialize(name, **args, &block)
        @defaults = {
          component: 'files-field',
        }.merge(@defaults || {})

        super(name, **args, &block)
        @is_array_param = true
        @file_field = true
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
      end

      def hydrate_field(fields, model, resource, view)
        storage_field = model.send(id)

        field = {
          value: [],
          files: [],
        }

        return field unless storage_field.attached?

        files = storage_field.each do |file|
          field[:value] << rails_blob_url(file, only_path: true)
          field[:files] << {
            id: file.id,
            filename: file.filename,
            path: rails_blob_url(file, only_path: true),
            is_image: self.is_image,
          }
        end

        field
      end
    end
  end
end
