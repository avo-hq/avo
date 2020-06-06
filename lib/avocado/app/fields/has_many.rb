require_relative 'field'

module Avocado
  module Fields
    class HasManyField < Field
      attr_accessor :resource_name

      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          component: 'has-many-field'
        }

        super(name, **args, &block)

        @resource_name = args[:resource_name]

        hide_on :index
      end

      def hydrate_resource(model, resource, view)
        return {} if [:create, :index].include? view

        fields = {}

        if resource_name.present?
          target_resource = resource_name.safe_constantize
        else
          target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name.to_s.singularize}".safe_constantize }
          # target_resource = App.get_resources.find { |r| abort "Avocado::Resources::#{id.to_s.singularize}".safe_constantize.inspect; abort "Avocado::Resources::#{id.to_s.singularize}".inspect; r.class == "Avocado::Resources.constants".safe_constantize }
        end
        fields[:relation_class] = target_resource.class.to_s
        fields[:path] = target_resource.url
        fields[:has_many_relationship] = target_resource.class.to_s

        fields
      end
    end
  end
end
