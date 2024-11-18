module Avo
  module Fields
    class RadioField < BaseField
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
    end
  end
end
