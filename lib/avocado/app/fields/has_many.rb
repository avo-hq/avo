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
        if view === :create
          return {
            relationship: :has_many,
          }
        end

        return {} if [:index].include? view

        fields = {}

        target_resource = get_target_resource model
        fields[:relation_class] = target_resource.class.to_s
        fields[:path] = target_resource.url
        fields[:relationship] = :has_many

        fields
      end

      def has_own_panel?
        true
      end

      def get_target_resource(model)
        if @resource.present?
          App.get_resources.find { |r| r.class == @resource }
        else
          class_name = model._reflections[id].options[:class_name].present? ? model._reflections[id].options[:class_name] : model._reflections[id].name
          App.get_resources.find { |r| r.class == "Avocado::Resources::#{class_name.to_s.camelcase.singularize}".safe_constantize }
        end
      end
    end
  end
end
