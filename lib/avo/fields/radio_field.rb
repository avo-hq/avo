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
    end
  end
end
