require_relative 'field'

module Avocado
  module Fields
    class HasManyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          component: 'has-many-field'
        }

        super(name, **args, &block)

        hide_on :index

        @resource = args[:resource]
      end

      def hydrate_resource(model, resource, view)
        return {} if [:create, :index].include? view

        fields = {}

        target_resource = get_target_resource
        fields[:relation_class] = target_resource.class.to_s
        fields[:path] = target_resource.url
        fields[:relationship] = :has_many
        fields[:relationship_name] = id

        fields
      end

      def has_own_panel?
        true
      end

      def get_target_resource
        if @resource.present?
          App.get_resources.find { |r| r.class == @resource }
        else
          App.get_resources.find { |r| r.class == "Avocado::Resources::#{name.to_s.singularize}".safe_constantize }
        end
      end
    end
  end
end
