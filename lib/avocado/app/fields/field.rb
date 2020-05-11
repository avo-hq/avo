module Avocado
  module Fields
    class Field
      attr_reader :name
      attr_reader :component
      attr_reader :can_be_updated
      attr_reader :sortable

      def initialize(*args)
        @name = args.first
        @component = 'field'
        @can_be_updated = true
        @sortable = false
      end

      def id
        name.to_s.parameterize
      end

      def fetch_for_resource(resource, view = :index)
        fetch_fields resource
      end

      # def fetch_for_resource_model(resource_model)
      #   fetch_fields resource_model
      # end

      def fetch_fields(model)
        is_class = false
        is_model = false

        fields = {
          id: id,
          name: name,
          component: component,
          can_be_updated: can_be_updated,
          sortable: sortable,
        }

        fields[:value] = model[id] if model_or_class(model) == 'class'

        fields
      end

      def model_or_class(model)
        if model.class == String
          return 'class'
        else
          return 'model'
        end
      end
    end
  end
end
