module Avo
  module Fields
    class HasOneField < Field
      attr_accessor :relation_method
      attr_accessor :display

      def initialize(name, **args, &block)
        @defaults = {
          updatable: true,
          partial_name: 'has-one-field',
        }

        super(name, **args, &block)

        hide_on :new

        @placeholder = I18n.t 'avo.choose_an_option'

        @relation_method = name.to_s.parameterize.underscore
        @display = args[:display].present? ? args[:display] : :show
      end

      def label
        value.send(target_resource.title)
      end

      def resource
        target_resource
      end

      def frame_name
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{id}_#{target_resource.model_class.to_s.underscore}"
      end

      def frame_url
        "#{Avo.configuration.root_path}/resources/#{@model.model_name.route_key}/#{@model.id}/#{id}/#{value.id}?frame_name=#{frame_name}"
      end

      def target_resource
        if @model._reflections[id.to_s].klass.present?
          App.get_resource_by_model_name @model._reflections[id.to_s].klass.to_s
        elsif @model._reflections[id.to_s].options[:class_name].present?
          App.get_resource_by_model_name @model._reflections[id.to_s].options[:class_name]
        else
          App.get_resource_by_name id.to_s
        end
      end

      def fill_field(model, key, value)
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
