module Avo
  module Fields
    class StarsField < BaseField
      attr_reader :max

      def initialize(name, **args, &block)
        super(name, **args, &block)

        @max = args[:max] || 5
      end
    end
  end
end
