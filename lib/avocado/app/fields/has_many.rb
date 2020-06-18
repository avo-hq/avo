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
      end

      def hydrate_resource(model, resource, view)
        return {} if [:create, :index].include? view

        fields = {}

        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name.to_s.singularize}".safe_constantize }
        fields[:relation_class] = target_resource.class.to_s
        fields[:path] = target_resource.url
        fields[:has_many_relationship] = target_resource.class.to_s

        fields
      end

      def has_own_panel?
        true
      end
    end
  end
end
