module Avo
  module Fields
    class FilesField < BaseField
      attr_accessor :is_image

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
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
          # Skip Capybara Nil files in tests
          next unless file.class === Capybara::RackTest::Form::NilUploadedFile

          model.send(key).attach file
        end

        model
      end
    end
  end
end
