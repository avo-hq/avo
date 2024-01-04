module Avo
  module Loaders
    class Loader
      attr_accessor :bag, :remove_scope_all

      def initialize
        @bag = []
      end

      def use(klass)
        @bag.push klass
      end
    end
  end
end
