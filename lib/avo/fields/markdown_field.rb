module Avo
  module Fields
    class MarkdownField < BaseField
      attr_reader :rows

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index
        add_string_prop args, :rows, default: 20
      end
    end
  end
end
