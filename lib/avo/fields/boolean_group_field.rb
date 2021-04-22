module Avo
  module Fields
    class BooleanGroupField < BaseField
      attr_reader :options

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @options = args[:options].present? ? args[:options] : {}
      end

      def to_permitted_param
        ["#{id}": []]
      end

      def fill_field(model, key, value)
        new_value = {}

        # Filter out the empty ("") value boolean group generates
        value = value.filter do |arr_value|
          arr_value.present?
        end

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
