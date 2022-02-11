module Avo
  module Fields
    class FilesField < BaseField
      attr_accessor :is_audio
      attr_accessor :is_image
      attr_accessor :direct_upload

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @is_audio = args[:is_audio].present? ? args[:is_audio] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
      end

      def view_component_name
        "FilesField"
      end

      def to_permitted_param
        {"#{id}": []}
      end

      def fill_field(model, key, value, params)
        return model unless model.methods.include? key.to_sym

        value.each do |file|
          # Skip empty values
          next unless file.present?

          model.send(key).attach file
        end

        model
      end
    end
  end
end
