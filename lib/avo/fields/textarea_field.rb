module Avo
  module Fields
    class TextareaField < TextField
      attr_reader :rows
      attr_reader :copyable

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @rows = args[:rows].present? ? args[:rows].to_i : 5
        add_boolean_prop args, :copyable
      end
    end
  end
end
