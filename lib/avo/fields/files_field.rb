module Avo
  module Fields
    class FilesField < BaseField
      attr_accessor :is_image

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "files-field"
        }.merge(@defaults || {})

        super(name, **args, &block)

        @is_array_param = true
        @file_field = true
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
      end

      def to_permitted_param
        {"#{id}": []}
      end

      def fill_field(model, key, value)
        return model unless model.methods.include? key.to_sym

        value.each do |file|
          model.send(key).attach file
        end

        model
      end
    end
  end
end
