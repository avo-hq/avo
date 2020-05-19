require_relative 'element'

module Avocado
  module Fields
    class Field
      include Avocado::Fields::Element

      attr_reader :id
      attr_reader :name
      attr_reader :component
      attr_reader :updatable
      attr_reader :sortable
      attr_reader :required
      attr_reader :nullable
      attr_reader :block

      def initialize(id_or_name, **args, &block)
        super(id_or_name, **args, &block)
        @defaults ||= {}

        args = @defaults.merge(args)

        @id = id_or_name.to_s.parameterize.underscore
        @name = args[:name] || id_or_name.to_s.camelize
        @component = args[:component] || 'field'
        @updatable = args[:updatable] || true
        @sortable = args[:sortable] || false
        @nullable = args[:nullable] || false
        @required = args[:required] || false

        @block = block

        # Set the visibility
        show_on args[:show_on] if args[:show_on].present?
        hide_on args[:hide_on] if args[:hide_on].present?
        only_on args[:only_on] if args[:only_on].present?
        except_on args[:except_on] if args[:except_on].present?
      end

      def fetch_for_resource(model, view = :index)
        fields = {
          id: id,
          name: name,
          component: component,
          updatable: updatable,
          sortable: sortable,
          required: required,
          nullable: nullable,
          computed: block.present?,
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
