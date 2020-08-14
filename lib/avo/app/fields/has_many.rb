module Avo
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

        fields
      end

      def has_own_panel?
        true
      end

      def get_target_resource(model)
        if @resource.present?
          App.get_resources.find { |r| r.class == @resource }
        else
          class_name = model._reflections[id.to_s].options[:class_name].present? ? model._reflections[id.to_s].options[:class_name] : model._reflections[id.to_s].name
          App.get_resources.find { |r| r.class == "Avo::Resources::#{class_name.to_s.camelcase.singularize}".safe_constantize }
        end
      end
    end
  end
end
