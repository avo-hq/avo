module Avo
  module Fields
    class HasOneField < HasBaseField
      attr_accessor :relation_method

      def initialize(id, **args, &block)
        hide_on :forms

        super(id, **args, &block)

        @placeholder ||= I18n.t "avo.choose_an_option"

        @relation_method = name.to_s.parameterize.underscore
      end

      def label
        field_label
      end

      def frame_url
        Avo::Services::URIService.parse(field_resource.record_path)
          .append_paths("associations", id, value.to_param)
          .append_query(query_params)
          .to_s
      end

      def fill_field(record, key, value, params)
        if value.blank?
          related_record = nil
        else
          related_class = record.class.reflections[name.to_s.downcase].class_name
          related_resource = Avo.resource_manager.get_resource_by_model_class(related_class)
          related_record = related_resource.find_record value
        end

        record.public_send(:"#{key}=", related_record)

        record
      end
    end
  end
end
