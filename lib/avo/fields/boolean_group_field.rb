module Avo
  module Fields
    class BooleanGroupField < BaseField
      def initialize(id, **args, &block)
        super(id, **args, &block)

        @options = args[:options] || {}
      end

      def options
        Avo::ExecutionContext.new(
          target: @options,
          record: record,
          resource: resource,
          view: view,
          field: self
        ).handle
      end

      def to_permitted_param
        ["#{id}": []]
      end

      def fill_field(record, _, values, _)
        new_value = {}

        # Reject empty values passed by hidden inputs
        values.reject! { |value| value == "" }

        # Cast values to booleans
        options.each do |key, _|
          new_value[key] = values.include? key.to_s
        end

        # Don't override existing values unless specified in options
        record[id] = (record[id] || {}).merge(new_value)

        record
      end
    end
  end
end
