module Avo
  module Fields
    class FilesField < BaseField
      attr_accessor :is_audio
      attr_accessor :is_image
      attr_accessor :direct_upload
      attr_accessor :accept
      attr_reader :display_filename
      attr_reader :hide_view_type_changer

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @is_audio = args[:is_audio].present? ? args[:is_audio] : false
        @is_image = args[:is_image].present? ? args[:is_image] : @is_avatar
        @direct_upload = args[:direct_upload].present? ? args[:direct_upload] : false
        @accept = args[:accept].present? ? args[:accept] : nil
        @display_filename = args[:display_filename].nil? ? true : args[:display_filename]
        @view_type = args[:view_type] || :grid
        @hide_view_type_changer = args[:hide_view_type_changer]
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

      def viewer_component
        "Avo::Fields::Common::Files::ViewType::#{view_type.to_s.capitalize}Component".constantize
      end

      def view_type
        (@resource.params.dig(:view_type) || @view_type).to_sym
      end
    end
  end
end
