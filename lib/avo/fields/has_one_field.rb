module Avo
  module Fields
    class HasOneField < BaseField
      attr_accessor :relation_method
      attr_accessor :display

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :new, :edit

        @placeholder ||= I18n.t "avo.choose_an_option"

        @relation_method = name.to_s.parameterize.underscore
        @display = args[:display].present? ? args[:display] : :show
      end

      def label
        value.send(target_resource.title)
      end

      def resource
        Avo::App.get_resource_by_model_name @model.class
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{id}"
      end

      def frame_url
        "#{Avo::App.root_path}/resources/#{resource.model_class.model_name.route_key}/#{@model.id}/#{id}/#{value.id}?turbo_frame=#{turbo_frame}"
      end

      def target_resource
        if @model._reflections[id.to_s].klass.present?
          Avo::App.get_resource_by_model_name @model._reflections[id.to_s].klass.to_s
        elsif @model._reflections[id.to_s].options[:class_name].present?
          Avo::App.get_resource_by_model_name @model._reflections[id.to_s].options[:class_name]
        else
          Avo::App.get_resource_by_name id.to_s
        end
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
