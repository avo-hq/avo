module Avo
  module Fields
    class BooleanGroupField < Field
      attr_reader :options

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'boolean-group-field',
          computable: true,
        }

        super(name, **args, &block)

        @options = args[:options].present? ? args[:options] : {}
      end

      def to_permitted_param
        ["#{id}": [] ]
      end

      def fill_field(model, key, value)
        new_value = {}

        # Cast values to booleans
        options.each do |id, label|
          new_value[id] = value.include? id.to_s
        end

        model[id] = new_value

        model
      end
    end
  end
end
