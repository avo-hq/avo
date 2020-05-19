require_relative './field'

module Avocado
  module Fields
    class BelongsToField < Field
      @defaults = {
        updatable: false,
        component: 'belongs-to-field'
      }

      def fetch_for_resource(model, view)
        fields = super(model)

        return fields if model_or_class(model) == 'class'

        fields[:is_relation] = true
        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name}".safe_constantize }
        relation_model = model.public_send(target_resource.name.underscore)
        fields[:value] = relation_model[target_resource.title] if relation_model.present?
        fields[:resource_name_plural] = target_resource.resource_name_plural

        fields
      end
    end
  end
end
