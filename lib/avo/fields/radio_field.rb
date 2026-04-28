module Avo
  module Fields
    class RadioField < BaseField
      attr_reader :display_as, :display_value

      def initialize(id, **args, &block)
        super

        @options = args[:options] || {}
        @display_as = args[:display_as] || :radio
        @display_value = args[:display_value] || false
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

      def label
        return "—" if value.nil?

        if display_value
          value
        else
          options.with_indifferent_access[value] || value
        end
      end

      def display_as_tabs?
        @display_as == :tabs
      end

      # Returns true when the field's value matches an option's key or value.
      # Supports both `{stored_value: "Label"}` and `{"Label": stored_value}` styles
      # so `default:` can be specified using either side of the options hash.
      def option_checked?(key, option_value)
        return false if value.nil?

        value.to_s == key.to_s || value.to_s == option_value.to_s
      end
    end
  end
end
