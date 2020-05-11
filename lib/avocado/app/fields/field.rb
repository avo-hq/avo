module Avocado
  module Fields
    class Field
      attr_reader :name
      attr_reader :component
      attr_reader :can_be_updated
      attr_reader :sortable
      attr_reader :required

      def initialize(name, **args)
        @name = name
        @component = 'field'
        @can_be_updated = true
        @sortable = false

        @required = args[:required] ? true : false
      end

      def id
        name.to_s.parameterize
      end

      def fetch_for_resource(model, view = :index)
        fields = {
          id: id,
          name: name,
          component: component,
          can_be_updated: can_be_updated,
          sortable: sortable,
          required: required,
        }

        fields[:value] = model[id] if model_or_class(model) == 'model'

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
