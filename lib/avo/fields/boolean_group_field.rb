module Avo
  module Fields
    class BooleanGroupField < BaseField
      attr_reader :options_from_args

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @options_from_args = args[:options].present? ? args[:options] : {}
      end

      def options
        Avo::ExecutionContext.new(
          target: options_from_args,
          record: record,
          resource: resource,
          view: view,
          field: self
        ).handle
      end

      def to_permitted_param
        ["#{id}": []]
      end

      def fill_field(model, key, value, params)
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
