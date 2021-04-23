module Avo
  module Fields
    class TrixField < BaseField
      attr_reader :always_show

      def initialize(id, **args, &block)
        super(id, **args, &block)

        hide_on :index

        @always_show = args[:always_show].present? ? args[:always_show] : false
      end
    end
  end
end
