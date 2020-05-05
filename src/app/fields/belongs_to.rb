require_relative './field'

module Avocado
  module Fields
    class BelongsToField < Field
      def initialize(*args)
        super

        @component = 'belongs-to-field'
      end

      def fetch_for_resource(resource, view)
        fields = super(resource)

        fields[:is_relation] = true
        target_resource = App.get_resources.find { |r| r.class == "Avocado::Resources::#{name}".safe_constantize }
        relation_model = resource.public_send(target_resource.name.underscore)
        fields[:value] = relation_model[target_resource.title]

        fields
      end
    end
  end
end
