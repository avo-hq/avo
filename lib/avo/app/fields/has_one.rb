module Avo
  module Fields
    class HasOneField < Field
      attr_accessor :relation_method

      def initialize(name, **args, &block)
        @defaults = {
          updatable: true,
          component: 'has-one-field',
        }

        super(name, **args, &block)

        hide_on :create

        @placeholder = 'Choose an option'

        @relation_method = name.to_s.parameterize.underscore
      end

      def hydrate_field(fields, model, resource, view)
        target_resource = get_related_resource(resource)
        fields[:relation_class] = target_resource.class.to_s

        relation_model = model.public_send(@relation_method)

        if relation_model.present?
          relation_model = model.public_send(@relation_method)
          fields[:value] = relation_model.send(target_resource.title)
          fields[:database_value] = relation_model[:id]
          fields[:link] = Avo::Resources::Resource.show_path(relation_model)
        end

        # Populate the options on show and edit
        fields[:options] = []

        if [:edit, :create].include? view
          fields[:options] = target_resource.model.all.map do |model|
            {
              value: model.id,
              label: model.send(target_resource.title)
            }
          end
        end

        fields[:resource_name_plural] = target_resource.resource_name_plural

        fields
      end

      def get_related_resource(resource)
        class_name = resource.model.reflections[name.to_s.downcase].class_name
        App.get_resources.find { |r| r.class == "Avo::Resources::#{class_name}".safe_constantize }
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
