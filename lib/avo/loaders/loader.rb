module Avo
  module Loaders
    class Loader
      attr_accessor :bag

      def initialize
        @bag = []
      end

      def use(klass)
        @bag.push klass
      end
    end
  end
end
