module Avo
  module Fields
    class HasManyField < Field
      def initialize(name, **args, &block)
        @defaults = {
          updatable: false,
          component: 'has-many-field'
        }
        @through = args[:through]

        super(name, **args, &block)

        hide_on :index

        @resource = args[:resource]
      end

      def hydrate_field(fields, model, resource, view)
        if view === :create
          return {
            relationship: :has_many,
          }
        end

        return {} if [:index].include? view

        target_resource = get_target_resource model
        fields[:relation_class] = target_resource.class.to_s
        fields[:path] = target_resource.url
        fields[:relationship] = :has_many
        fields[:through] = @through
        fields[:relationship_model] = target_resource.model.name

        fields
      end

      def has_own_panel?
        true
      end

      def get_target_resource(model)
        if @resource.present?
          App.get_resources.find { |r| r.class == @resource }
        else
          class_name = model._reflections[id.to_s].options[:class_name].present? ? model._reflections[id.to_s].options[:class_name] : model._reflections[id.to_s].klass.name
          App.get_resource_by_model_name class_name
        end
      end
    end
  end
end
