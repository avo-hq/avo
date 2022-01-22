module Avo
  module Fields
    class HasBaseField < BaseField
      def resource
        Avo::App.get_resource_by_model_name @model.class
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{id}"
      end

      def frame_url
        "#{@resource.record_path}/#{id}/#{value.id}?turbo_frame=#{turbo_frame}"
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
    end
  end
end
