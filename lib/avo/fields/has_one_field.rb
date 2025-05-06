module Avo
  module Fields
    class HasOneField < FrameBaseField

      class_attribute :supported_options, default: {}
      Avo::Fields::COMMON_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end

      Avo::Fields::FRAME_BASE_OPTIONS.each do |common_option, hash|
        supports common_option, hash
      end


      include Avo::Fields::Concerns::Nested

      attr_reader :attach_fields,
        :attach_scope

      def initialize(id, **args, &block)
        initialize_nested(**args)

        if @nested[:on]
          nested_on = Array.wrap(@nested[:on])

          if !nested_on.include?(:new)
            hide_on :new
          elsif !nested_on.include?(:edit)
            hide_on :edit
          end
        else
          hide_on :forms
        end

        super(id, **args, &block)

        @placeholder ||= I18n.t "avo.choose_an_option"
        @attach_fields = args[:attach_fields]
        @attach_scope = args[:attach_scope]
      end

      def label
        field_label
      end

      def frame_url
        Avo::Services::URIService.parse(field_resource.record_path)
          .append_paths(id, value.to_param)
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

      def is_searchable? = false
    end
  end
end
