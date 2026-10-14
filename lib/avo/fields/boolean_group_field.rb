module Avo
  module Fields
    class BooleanGroupField < BaseField
      def initialize(id, **args, &block)
        super

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

        # Don't override existing values unless specified in options.
        # Drop the stored copy of each option first: a json column hands its keys back as Strings while options are
        # usually Symbols, and a Hash holding both makes json 3 raise "detected duplicate key".
        option_keys = new_value.keys.map(&:to_s)
        stored_value = (record.send(id) || {}).reject { |key, _| option_keys.include?(key.to_s) }
        record.send(:"#{id}=", stored_value.merge(new_value))

        record
      end
    end
  end
end
