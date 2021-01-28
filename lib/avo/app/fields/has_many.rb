module Avo
  module Fields
    class HasManyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          partial_name: 'has-many-field'
        }
        @through = args[:through]

        super(name, **args, &block)

        hide_on :index

        @resource = args[:resource]
      end

      def has_own_panel?
        true
      end

      def frame_name
        "#{self.class.name.demodulize.to_s.underscore}_#{id}_#{target_resource.model_class.to_s.underscore}"
      end

      def frame_url
        if @display == :show
          "#{Avo.configuration.root_path}/resources/#{target_resource.model_class.model_name.route_key}/#{value.id}?frame_name=#{frame_name}&via_relation=has_one&via_resource_name=#{@model.model_name.route_key}&via_resource_id=#{@model.id}&via_relation_param=#{id}"
        else
          "#{Avo.configuration.root_path}/resources/#{target_resource.model_class.model_name.route_key}?frame_name=#{frame_name}&via_relation=has_many&via_relation_param=#{id}&via_resource_name=#{@resource.model_class}&via_resource_id=#{@model.id}"
        end
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
