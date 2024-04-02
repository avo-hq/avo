module Avo
  module Fields
    class TiptapField < BaseField
      attr_reader :always_show

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show] || false
      end
    end
  end
end
