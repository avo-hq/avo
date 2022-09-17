module Avo
  module Fields
    class TextareaField < TextField
      attr_reader :rows

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @rows = args[:rows].present? ? args[:rows].to_i : 5
      end
    end
  end
end
