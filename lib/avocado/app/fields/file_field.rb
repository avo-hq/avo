require_relative 'field'

module Avocado
  module Fields
    class FileField < Field
      include Rails.application.routes.url_helpers
      attr_accessor :is_avatar
      attr_accessor :is_image

      def initialize(name, **args, &block)
        @defaults = {
          component: 'file-field',
        }.merge(@defaults || {})

        super(name, **args, &block)
        @file_field = true
        @is_avatar = args[:is_avatar].present? ? args[:is_avatar] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
      end

      def is_file_field
        true
      end

      def hydrate_resource(model, resource, view)
        storage_field = model.send(id)

        field = {
          is_file_field: true,
        }

        return field unless storage_field.attached?

        # @todo: refactor representable into `value` maybe?
        field[:field_id] = storage_field.id
        field[:filename] = storage_field.filename
        field[:value] = rails_blob_url(storage_field, only_path: true)
        # abort self.inspect
        field[:is_image] = self.is_image

        field
      end
    end
  end
end
