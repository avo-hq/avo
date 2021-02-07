module Avo
  module Fields
    class HasAndBelongsToManyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          partial_name: 'has-many-field'
        }

        super(name, **args, &block)

        hide_on :index

        @resource = args[:resource]
      end

      def frame_name
        "#{self.class.name.demodulize.to_s.underscore}_#{id}_#{target_resource.model_class.to_s.underscore}"
      end

      def frame_url
        "#{Avo.configuration.root_path}/resources/#{@model.model_name.route_key}/#{@model.id}/#{id}?frame_name=#{frame_name}"
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
    end
  end
end
