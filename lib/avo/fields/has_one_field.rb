module Avo
  module Fields
    class HasOneField < HasBaseField
      attr_accessor :relation_method

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :new, :edit

        @placeholder ||= I18n.t "avo.choose_an_option"

        @relation_method = name.to_s.parameterize.underscore
      end

      def label
        value.send(target_resource.title)
      end

      def resource
        Avo::App.get_resource_by_model_name @model.class
      end

      def frame_url
        "#{@resource.record_path}/#{id}/#{value.id}?turbo_frame=#{turbo_frame}"
      end

      def fill_field(model, key, value, params)
        if value.blank?
          related_model = nil
        else
          related_class = model.class.reflections[name.to_s.downcase].class_name
          related_model = related_class.safe_constantize.find value
        end

        model.public_send("#{key}=", related_model)

        model
      end
    end
  end
end
